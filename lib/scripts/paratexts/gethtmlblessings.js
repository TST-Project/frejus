const fs = require('fs');
const jsdom = require('jsdom');
const SaxonJS = require('saxon-js');
const Sanscript = require('./sanscript');

const xsltSheet = fs.readFileSync('xslt/tei-to-html-reduced.json',{encoding:'utf-8'});

const dir = '../../../mss/';

fs.readdir(dir,function(err,files) {
    if(err)
        return console.log(err);
    const flist = [];
    files.forEach(function(f) {
        if(/^[^_].+\.xml$/.test(f))
            flist.push(dir+f);
    });
    readfiles(flist);
});

const getRepo = (xmlDoc) => {

    const names = new Map([
        ['Bibliothèque nationale de France. Département des Manuscrits','BnF'],
        ['Bibliothèque nationale de France. Département des Manuscrits.','BnF'],
        ['Staats- und UniversitätsBibliothek Hamburg Carl von Ossietzky','Hamburg Stabi'],
        ['Bodleian Library, University of Oxford','Oxford'],
        ['Cambridge University Library','Cambridge'],
        ['Bibliothèque universitaire des langues et civilisations','BULAC'],
        ['Private collection','private']
    ]);
    const repo = xmlDoc.querySelector('repository > orgName').textContent.replace(/\s+/g,' ');
    return names.get(repo); 
};

const getCote = function(xmlDoc) {
    const txt = xmlDoc.querySelector('idno[type="shelfmark"]').textContent || '';
    const sort = txt.replace(/\d+/g,((match) => {
        return match.padStart(4,'0');
    }));
    return {text: txt, sort: sort};
};

const getBlessings = function(xmlDoc) {
    return xmlDoc.querySelectorAll('seg[function="blessing"], desc[type~="blessing"]');
};

const getPrev = function(e) {
    if(e.previousElementSibling) return e.previousElementSibling;
    if(e.parentNode.previousElementSibling) {
        if(e.parentNode.previousElementSibling.lastChild)
            return e.parentNode.previousElementSibling.lastElementChild;
        else return e.parentNode.previousElementSibling;
    }
    return false;
};

const isFolio = (str) => str === 'folio' || str === 'page' || str === 'plate';

const getMilestone = function(el) {
    const getUnit = (el) => {
        const m = el.ownerDocument.querySelector('extent > measure');
        if(m) return m.getAttribute('unit');
        return '';
    };

    var p = getPrev(el);
    while(p) {
        if(!p) return false;
        if(p.nodeName === 'text') return false;
        if(p.nodeName === 'pb' || 
            (p.nodeName === 'milestone' && isFolio(p.getAttribute('unit')) )
        ) 
            return (p.getAttribute('unit') || getUnit(p) || '') + ' ' + 
                   (p.getAttribute('n') || '');
        p = getPrev(p);
    }
};

const getPlacement = function(el) {
    var p = getPrev(el);
    while(p) {
        if(!p) return '';
        if(p.nodeName === 'text') return '';
        if(p.nodeName === 'milestone') {
            if(isFolio(p.getAttribute('unit')) ) return ''; 
            const u = (p.getAttribute('unit') || '').replace(/-/g,' ');
            return u + ' ' + (p.getAttribute('n') || '');
        }
        p = getPrev(p);
    }
};
const fileredux = function(acc,cur,cur1) {
    
    var milestone, inner, placement, synch;
    if(cur.nodeName === 'seg') {
        milestone = getMilestone(cur);
        placement = getPlacement(cur) || '';
        synch = cur.closest('text').getAttribute('synch');
        inner = cur.innerHTML;
    }
    else {
        const loc = cur.querySelector('locus');
        const subtype = cur.getAttribute('subtype') || '';
        milestone = loc ? loc.textContent : '';
        placement = subtype.replace(/\s/g,', ').replace(/-/g,' ');
        synch = cur.getAttribute('synch');
        const q = cur.querySelector('q,quote');
        inner = q ? q.innerHTML : '';
    }
    const unit = synch ? synch.replace(/^#/,'') : '';
    const processed = SaxonJS.transform({
        stylesheetText: xsltSheet,
        sourceText: '<TEI xmlns="http://www.tei-c.org/ns/1.0">'+inner+'</TEI>',
        destination: 'serialized'},'sync');
    const res = processed.principalResult || '';
    const txt = Sanscript.t(
        res.replace(/[\n\s]+/g,' ').replace(/\s%nobreak%/g,'').trim(),
        'tamil','iast');
    return acc + 
`<tr>
<td>
${txt}
</td>
<td><a href="${cur1.fname}">${cur1.cote.text}</a></td>
<td>
${cur1.repo}
</td>
<td>
${cur1.title}
</td>
<td>
${unit}
</td>
<td>
${milestone}
</td>
<td>
${placement}
</td>
</tr>\n`;
};

const readfiles = function(arr) {
    const tab = arr.map((f) => 
    {
        const str = fs.readFileSync(f,{encoding:'utf-8'});
        const fname = `../mss/${f}`;
        const dom = new jsdom.JSDOM('');
        const parser = new dom.window.DOMParser();
        const xmlDoc = parser.parseFromString(str,'text/xml');
        const cote = getCote(xmlDoc);
        const repo = getRepo(xmlDoc);
        const blessings = getBlessings(xmlDoc);
        return {
            cote: cote,
            title: xmlDoc.querySelector('titleStmt > title').textContent.replace(/&/g,'&#38;'),
            repo: repo,
            fname: fname,
            blessings: blessings
        };
    });
    /*
    tab.sort((a,b) => {
        if(a.sort  b.sort) return -1;
        else return 1;
    });
    */
    const template = new jsdom.JSDOM(fs.readFileSync('blessings-template.html',{encoding:'utf8'})).window.document;
    const table = template.querySelector('#index').firstElementChild;
    const tstr = tab.reduce((acc, cur) => {
        if(cur.blessings.length > 0) {
            const lines = [...cur.blessings].reduce((acc2,cur2) => fileredux(acc2,cur2,cur),'');
            return acc + lines;
        }
        else return acc;
    },'');
    const thead = '<tr id="head"><th>Blessing</th><th class="sorttable_alphanum">Shelfmark</th><th>Repository</th><th>Title</th><th>Unit</th><th>Page/folio</th><th>Placement</th></tr>';
    table.innerHTML = thead + tstr;
    fs.writeFile('blessings.html',template.documentElement.outerHTML,{encoding: 'utf8'},function(){return;});
};
