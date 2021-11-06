'use strict';

window.TSTViewer = (function() {
    const _state = {
        manifest: null,
    };
    
    const Mirador = window.Mirador || null;
    const Transliterate = window.Transliterate || null;

    const init = function() {

        // load image viewer if facsimile available
        const viewer = document.getElementById('viewer');
        if(viewer) {
            _state.manifest = viewer.dataset.manifest;
            _state.mirador = newMirador('viewer',viewer.dataset.manifest,viewer.dataset.start);
        }        
        
        // initialize events for the record text
        const recordcontainer = document.getElementById('recordcontainer');

        cleanLb(recordcontainer);

        Transliterate.init(recordcontainer);
        
        // start all texts in diplomatic view
        for(const l of recordcontainer.querySelectorAll('.line-view-icon'))
            lineView(l);

        recordcontainer.addEventListener('click',events.docClick);
        recordcontainer.addEventListener('mouseover',events.docMouseover);
    };

    const newMirador = function(id,manifest,start = 0) {
        const viewer = Mirador.viewer({
            id: id,
            windows: [{
                id: 'win1',
                loadedManifest: manifest,
                canvasIndex: start
            }],
            window: {
                allowClose: false,
                allowFullscreen: false,
                allowMaximize: false,
                defaultSideBarPanel: 'attribution',
                sideBarOpenByDefault: false,
                imageToolsEnabled: true,
                imageToolsOpen: true,
            },
            workspace: {
                showZoomControls: true,
                type: 'mosaic',
            },
            workspaceControlPanel: {
                enabled: false,
            }
        });
        const act = Mirador.actions.setWindowViewType('win1','single');
        viewer.store.dispatch(act);
        return viewer;
    };

    const killMirador = function(win = _state.mirador) {
        if(win) {
            const act = Mirador.actions.removeWindow('win1');
            win.store.dispatch(act);
        }
    };

    const events = {

        docClick: function(e) {
            const locel = e.target.closest('[data-loc]');
            if(locel) {
                jumpTo(locel.dataset.loc);
                return;
            }
            const lineview = e.target.closest('.line-view-icon');
            if(lineview) {
                lineView(lineview);
                return;
            }
            
            if(e.target.dataset.hasOwnProperty('scroll')) {
                e.preventDefault();
                const el = document.getElementById(e.target.href.split('#')[1]);
                el.scrollIntoView({behavior: 'smooth', inline:'end'});
            }
        },
        
        docMouseover: function(e) {
            var targ = e.target.closest('[data-anno]');
            while(targ && targ.hasAttribute('data-anno')) {
                toolTip.make(e,targ);
                targ = targ.parentNode;
            }

        },
    };

    const toolTip = {
        make: function(e,targ) {
            const toolText = targ.dataset.anno;
            if(!toolText) return;

            var tBox = document.getElementById('tooltip');
            const tBoxDiv = document.createElement('div');

            if(tBox) {
                for(const kid of tBox.childNodes) {
                    if(kid.myTarget === targ)
                        return;
                }
                tBoxDiv.appendChild(document.createElement('hr'));
            }
            else {
                tBox = document.createElement('div');
                tBox.id = 'tooltip';
                tBox.style.top = (e.clientY + 10) + 'px';
                tBox.style.left = e.clientX + 'px';
                tBox.style.opacity = 0;
                tBox.style.transition = 'opacity 0.2s ease-in';
                document.body.appendChild(tBox);
                tBoxDiv.myTarget = targ;
            }

            tBoxDiv.appendChild(document.createTextNode(toolText));
            tBoxDiv.myTarget = targ;
            tBox.appendChild(tBoxDiv);
            targ.addEventListener('mouseleave',toolTip.remove,{once: true});
            window.getComputedStyle(tBox).opacity;
            tBox.style.opacity = 1;
        },
        remove: function(e) {
            const tBox = document.getElementById('tooltip');
            if(tBox.children.length === 1) {
                tBox.remove();
                return;
            }

            const targ = e.target;
            for(const kid of tBox.childNodes) {
                if(kid.myTarget === targ) {
                    kid.remove();
                    break;
                }
            }
            if(tBox.children.length === 1) {
                const kid = tBox.firstChild.firstChild;
                if(kid.tagName === 'HR')
                    kid.remove();
            }
        },
    };

    const jumpTo = function(n) {
        const manif = _state.mirador.store.getState().manifests[_state.manifest].json;
        // n-1 because f1 is image 0
        const act = Mirador.actions.setCanvas('win1',manif.sequences[0].canvases[n-1]['@id']);
        _state.mirador.store.dispatch(act);
    };

    const cleanLb = function(par) {
        const lbs = par.querySelectorAll('[data-nobreak]');
        for(const lb of lbs) {
            const prev = lb.previousSibling;
            if(prev && prev.nodeType === 3)
                prev.data = prev.data.trimEnd();
        }
    };

    const lineView = function(icon) {
        const par = icon.closest('.teitext');
        if(icon.classList.contains('diplo')) {
            par.classList.remove('diplo');
            const els = par.querySelectorAll('.diplo');
            for(const el of els)
                el.classList.remove('diplo');
            icon.title = 'diplomatic view';
        }
        else {
            icon.classList.add('diplo');
            par.classList.add('diplo');
            const els = par.querySelectorAll('p,div.lg,div.l,.pb,.lb,.caesura,.milestone');
            for(const el of els)
                el.classList.add('diplo');
            icon.title = 'paragraph view';
        }

    };

    //window.addEventListener('load',init);

    return {
        init: init,
        newMirador: newMirador,
        killMirador: killMirador
    };
}());
