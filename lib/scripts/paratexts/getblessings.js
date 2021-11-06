const fs = require('fs');
const jsdom = require('jsdom');
const SaxonJS = require('saxon-js');
const Sanscript = require('./sanscript');

const xsltSheet = fs.readFileSync('xslt/blessings.json',{encoding:'utf-8'});
const xsltSheet_clean = fs.readFileSync('xslt/blessings-clean.json',{encoding:'utf-8'});

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
    const processed2 = SaxonJS.transform({
        stylesheetText: xsltSheet_clean,
        sourceText: '<TEI xmlns="http://www.tei-c.org/ns/1.0">'+inner+'</TEI>',
        destination: 'serialized'},'sync');
    const txt = processed.principalResult.replace(/[\n\s]+/g,' ').replace(/\s%nobreak%/g,'').trim();
    const cleantxt = Sanscript.t(
        processed2.principalResult.replace(/[\n\s]+/g,' ').replace(/\s%nobreak%/g,'').replace(/[|•-]|=(?=\w)/g,'').trim(),
        'tamil','iast');
    const tunai = Array.from(cleantxt.matchAll(/tuṇai/g)).length;
    return acc + 
`<table:table-row table:style-name="ro2">
<table:table-cell table:style-name="ce2" office:value-type="string" calcext:value-type="string">
${txt}
</table:table-cell>
<table:table-cell table:style-name="ce2" office:value-type="string" calcext:value-type="string">
${cleantxt}
</table:table-cell>
<table:table-cell office:value-type="string" calcext:value-type="string">
<text:p>${cur1.cote.text}</text:p>
</table:table-cell>
<table:table-cell office:value-type="string" calcext:value-type="string">
<text:p>${cur1.repo}</text:p>
</table:table-cell>
<table:table-cell office:value-type="string" calcext:value-type="string">
<text:p>${cur1.title}</text:p>
</table:table-cell>
<table:table-cell office:value-type="string" calcext:value-type="string">
<text:p>${unit}</text:p>
</table:table-cell>
<table:table-cell office:value-type="string" calcext:value-type="string">
<text:p>${milestone}</text:p>
</table:table-cell>
<table:table-cell office:value-type="string" calcext:value-type="string">
<text:p>${placement}</text:p>
</table:table-cell>
<table:table-cell office:value-type="string" calcext:value-type="string">
<text:p>${tunai}</text:p>
</table:table-cell>
</table:table-row>\n`;
};

const readfiles = function(arr) {
    const tab = arr.map((f) => 
    {
        const str = fs.readFileSync(f,{encoding:'utf-8'});
        const dom = new jsdom.JSDOM('');
        const parser = new dom.window.DOMParser();
        const xmlDoc = parser.parseFromString(str,'text/xml');
        const cote = getCote(xmlDoc);
        const repo = xmlDoc.querySelector('repository > orgName').textContent;
        const blessings = getBlessings(xmlDoc);
        return {
            cote: cote,
            title: xmlDoc.querySelector('titleStmt > title').textContent.replace(/&/g,'&#38;'),
            repo: repo,
            blessings: blessings
        };
    });
    /*
    tab.sort((a,b) => {
        if(a.sort  b.sort) return -1;
        else return 1;
    });
    */
    const thead = fs.readFileSync('blessings-template.fods',{encoding:'utf-8'});
    const tstr = tab.reduce((acc, cur) => {
        if(cur.blessings.length > 0) {
            const lines = [...cur.blessings].reduce((acc2,cur2) => fileredux(acc2,cur2,cur),'');
            return acc + lines;
        }
        else return acc;
    },thead);
    const end = '</table:table></office:spreadsheet></office:body></office:document>';
    fs.writeFile('blessings.fods',tstr + end,{encoding: 'utf8'},function(){return;});
};
