# Fixes the following error:
#    [coc.nvim] Unable to load global extension at 
#    ~/fictional-couscous/files/.config/coc/extensions/node_modules/coc-ccls:
#    main file ./lib/extension.js  not found, you may need to build the project.

cd ~/.config/coc/extensions/node_modules/coc-ccls
ln -s node_modules/ws/lib lib
