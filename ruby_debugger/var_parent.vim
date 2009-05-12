" Inherits VarParent from VarChild
let s:VarParent = copy(s:VarChild)


" Renders data of the variable
function! s:VarParent.render()
  return self._render(0, 0, [], len(self.children) ==# 1)
endfunction



" Initializes new variable with childs
function! s:VarParent.new(attrs)
  if !has_key(a:attrs, 'hasChildren') || a:attrs['hasChildren'] != 'true'
    throw "RubyDebug: VarParent must be initialized with hasChildren = true"
  endif
  let new_variable = copy(self)
  let new_variable.attributes = a:attrs
  let new_variable.parent = {}
  let new_variable.is_open = 0
  let new_variable.level = 0
  let new_variable.children = []
  let new_variable.type = "VarParent"
  let s:Var.id += 1
  let new_variable.id = s:Var.id
  return new_variable
endfunction


function! s:VarParent.open()
  let self.is_open = 1
  call self._init_children()
  return 0
endfunction


function! s:VarParent.close()
  let self.is_open = 0
  call s:variables_window.display()
  if has_key(g:RubyDebugger, "current_variable")
    unlet g:RubyDebugger.current_variable
  endif
  return 0
endfunction



function! s:VarParent._init_children()
  "remove all the current child nodes
  let self.children = []

  if has_key(self.attributes, 'objectId')
    let g:RubyDebugger.current_variable = self
    call g:RubyDebugger.send_command('var instance ' . self.attributes.objectId)
  endif

endfunction


function! s:VarParent.add_childs(childs)
  if type(a:childs) == type([])
    for child in a:childs
      let child.parent = self
      let child.level = self.level + 1
    endfor
    call extend(self.children, a:childs)
  else
    let a:childs.parent = self
    let child.level = self.level + 1
    call add(self.children, a:childs)
  end
endfunction


function! s:VarParent.find_variable(attrs)
  if self._match_attributes(a:attrs)
    return self
  else
    for child in self.children
      let result = child.find_variable(a:attrs)
      if result != {}
        return result
      endif
    endfor
  endif
  return {}
endfunction


function! s:VarParent.find_variables(attrs)
  let variables = []
  if self._match_attributes(a:attrs)
    call add(variables, self)
  endif
  for child in self.children
    call extend(variables, child.find_variables(a:attrs))
  endfor
  return variables
endfunction


