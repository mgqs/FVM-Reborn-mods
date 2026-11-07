const fs=require('fs'),path=require('path');
const dir=__dirname, root=path.join(dir,'..','..');
const html=fs.readFileSync(path.join(dir,'index.html'),'utf8');
const rd=p=>fs.readFileSync(path.join(root,'datafiles','level_data',p),'utf8').replace(/\u0000/g,'');
const samples={ longyuan:rd('longyuan/longyuan_1_hard.json'), undersea:rd('undersea/tuna_current.json') };
const mk=(page,sample)=>html.replace('</body>',()=>`<script>
window.addEventListener('load',()=>{try{
  ${sample?`const raw=${JSON.stringify(samples[sample])};
  S.level=normalizeLevel(JSON.parse(raw)); S.wave=0; S.sub=0; S.cell={r:0,c:0};`:''}
  renderAll(); gotoPage(${page});
}catch(e){document.body.insertAdjacentHTML('afterbegin','<div style="color:red">ERR '+e.message+'</div>');}});
</script></body>`);
for(const [n,pg,s] of [['0',0,null],['1',1,'longyuan'],['2',2,'longyuan'],['1b',1,'undersea']])
  fs.writeFileSync(path.join(dir,'_shot'+n+'.html'), mk(pg,s));
console.log('written');