t.on('select', function (target,data) { 
  alert('select'); 
});
t.on('expand', function (target,leaves) { 
  alert('expand'); 
});
t.on('expandAll', function () { 
  alert('expand'); 
});
t.on('collapse', function (target,leaves) { 
  alert('collapse'); 
});
t.on('collapseAll', function () { 
  alert('collapse'); 
});

https://www.cssscript.com/create-a-simple-tree-view-using-vanilla-javascript-js-treeview/
