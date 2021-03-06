" Vim completion script
" Language:             Ruby
" Maintainer:           Mark Guzman <segfault@hasno.info>
" Info:                 $Id: rubycomplete.vim,v 1.5 2006/04/29 21:54:43 vimboss Exp $
" URL:                  http://vim-ruby.rubyforge.org
" Anon CVS:             See above site
" Release Coordinator:  Doug Kearns <dougkearns@gmail.com>
" ----------------------------------------------------------------------------
"
" Ruby IRB/Complete author: Keiju ISHITSUKA(keiju@ishitsuka.com)
" ----------------------------------------------------------------------------

" {{{ requirement checks
if !has('ruby')
    echohl ErrorMsg
    echo "Error: Required vim compiled with +ruby"
    echohl None
    finish
endif

if version < 700
    echohl ErrorMsg
    echo "Error: Required vim >= 7.0"
    echohl None
    finish
endif
" }}} requirement checks

if !exists("g:rubycomplete_rails")
    let g:rubycomplete_rails = 0
endif

if !exists("g:rubycomplete_classes_in_global")
    let g:rubycomplete_classes_in_global = 0
endif

" {{{ vim-side support functions
function! GetBufferRubyModule(name)
    let [snum,enum] = GetBufferRubyEntity(a:name, "module")
    return snum . '..' . enum
endfunction

function! GetBufferRubyClass(name)
    let [snum,enum] = GetBufferRubyEntity(a:name, "class")
    return snum . '..' . enum
endfunction

function! GetBufferRubySingletonMethods(name)
endfunction

function! GetBufferRubyEntity( name, type )
    let stopline = 1
    let crex = '^\s*' . a:type . '\s*' . a:name . '\s*\(<\s*.*\s*\)\?\n*\(\(\s\|#\).*\n*\)*\n*\s*end$'
    let [lnum,lcol] = searchpos( crex, 'nbw')
    if lnum == 0 && lcol == 0
        return [0,0]
    endif

    let [enum,ecol] = searchpos( crex, 'nebw')
    if lnum > enum
        let realdef = getline( lnum )
        let crexb = '^' . realdef . '\n*\(\(\s\|#\).*\n*\)*\n*\s*end$'
        let [enum,ecol] = searchpos( crexb, 'necw' )
    endif
    " we found a the class def
    return [lnum,enum]
endfunction

function! IsInClassDef()
    let [snum,enum] = GetBufferRubyEntity( '.*', "class" )
    let ret = 'nil'
    let pos = line('.')

    if snum < pos && pos < enum
        let ret = snum . '..' . enum
    endif

    return ret
endfunction

function! GetRubyVarType(v)
    let stopline = 1
    let vtp = ''
    let pos = getpos('.')
    let [lnum,lcol] = searchpos('^\s*#\s*@var\s*'.a:v.'\>\s\+[^ \t]\+\s*$','nb',stopline)
    if lnum != 0 && lcol != 0
        call setpos('.',pos)
        let str = getline(lnum)
        let vtp = substitute(str,'^\s*#\s*@var\s*'.a:v.'\>\s\+\([^ \t]\+\)\s*$','\1','')
        return vtp
    endif
    call setpos('.',pos)
    if g:rubycomplete_rails == 1 && g:rubycomplete_rails_loaded == 1
        let ctors = '\(now\|new\|open\|get_instance\|find\|create\)'
    else
        let ctors = '\(now\|new\|open\|get_instance\)'
    endif

    let [lnum,lcol] = searchpos(''.a:v.'\>\s*[+\-*/]*=\s*\([^ \t]\+.' . ctors .'\>\|[\[{"''/]\|%r{\|[A-Za-z0-9@:\-()]\+...\?\)','nb',stopline)
    if lnum != 0 && lcol != 0
        let str = matchstr(getline(lnum),'=\s*\([^ \t]\+.' . ctors . '\>\|[\[{"''/]\|%r{\|[A-Za-z0-9@:\-()]\+...\?\)',lcol)
        let str = substitute(str,'^=\s*','','')
        call setpos('.',pos)
        if str == '"' || str == ''''
            return 'String'
        elseif str == '['
            return 'Array'
        elseif str == '{'
            return 'Hash'
        elseif str == '/' || str == '%r{'
            return 'Regexp'
        elseif strlen(str) >= 4 && stridx(str,'..') != -1
            return 'Range'
        elseif strlen(str) > 4
            let l = stridx(str,'.')
            return str[0:l-1]
        end
        return ''
    endif
    call setpos('.',pos)
    return ''
endfunction

"}}} vim-side support functions

function! rubycomplete#Complete(findstart, base)
     "findstart = 1 when we need to get the text length
    if a:findstart
        let line = getline('.')
        let idx = col('.')
        while idx > 0
            let idx -= 1
            let c = line[idx-1]
            if c =~ '\w'
                continue
            elseif ! c =~ '\.'
                idx = -1
                break
            else
                break
            endif
        endwhile

        return idx
    "findstart = 0 when we need to return the list of completions
    else
        let g:rubycomplete_completions = []
        execute "ruby get_completions('" . a:base . "')"
        return g:rubycomplete_completions
    endif
endfunction


function! s:DefRuby()
ruby << RUBYEOF
# {{{ ruby completion
RailsWords = [
      "has_many", "has_one",
      "belongs_to",
    ]

ReservedWords = [
      "BEGIN", "END",
      "alias", "and",
      "begin", "break",
      "case", "class",
      "def", "defined", "do",
      "else", "elsif", "end", "ensure",
      "false", "for",
      "if", "in",
      "module",
      "next", "nil", "not",
      "or",
      "redo", "rescue", "retry", "return",
      "self", "super",
      "then", "true",
      "undef", "unless", "until",
      "when", "while",
      "yield",
    ]

Operators = [ "%", "&", "*", "**", "+",  "-",  "/",
      "<", "<<", "<=", "<=>", "==", "===", "=~", ">", ">=", ">>",
      "[]", "[]=", "^", ]


def load_requires
  buf = VIM::Buffer.current
  enum = buf.line_number
  nums = Range.new( 1, enum )
  nums.each do |x|
    ln = buf[x]
    begin
      eval( "require %s" % $1 ) if /.*require\s*(.*)$/.match( ln )
    rescue Exception
      #ignore?
    end
  end
end

def load_buffer_class(name)
  classdef = get_buffer_entity(name, 'GetBufferRubyClass("%s")')
  return if classdef == nil

  pare = /^\s*class\s*(.*)\s*<\s*(.*)\s*\n/.match( classdef )
  load_buffer_class( $2 ) if pare != nil

  mixre = /.*\n\s*include\s*(.*)\s*\n/.match( classdef )
  load_buffer_module( $2 ) if mixre != nil

  eval classdef
end

def load_buffer_module(name)
  classdef = get_buffer_entity(name, 'GetBufferRubyModule("%s")')
  return if classdef == nil

  eval classdef
end

def get_buffer_entity(name, vimfun)
  return nil if /(\"|\')+/.match( name )
  buf = VIM::Buffer.current
  nums = eval( VIM::evaluate( vimfun % name ) )
  return nil if nums == nil
  return nil if nums.min == nums.max && nums.min == 0

  cur_line = VIM::Buffer.current.line_number
  classdef = ""
  nums.each do |x|
    if x != cur_line
      ln = buf[x]
      classdef += "%s\n" % ln
    end
  end

  return classdef
end

def get_var_type( receiver )
  if /(\"|\')+/.match( receiver )
    "String"
  else
    VIM::evaluate("GetRubyVarType('%s')" % receiver)
  end
end

def get_buffer_classes()
  # this will be a little expensive.
  allow_aggressive_load = VIM::evaluate('g:rubycomplete_classes_in_global')
  return [] if allow_aggressive_load != '1'

  buf = VIM::Buffer.current
  eob = buf.length
  ret = []
  rg = 1..eob

  rg.each do |x|
    if /^\s*class\s*([A-Za-z0-9_-]*)(\s*<\s*([A-Za-z0-9_:-]*))?\s*/.match( buf[x] )
      ret.push $1
    end
  end

  return ret
end

def load_rails()
  allow_rails = VIM::evaluate('g:rubycomplete_rails')
  return if allow_rails != '1'

  buf_path = VIM::evaluate('expand("%:p")')
  file_name = VIM::evaluate('expand("%:t")')
  path = buf_path.gsub( file_name, '' )
  path.gsub!( /\\/, "/" )
  pup = [ "./", "../", "../../", "../../../", "../../../../" ]
  pok = nil

  pup.each do |sup|
    tpok = "%s%sconfig" % [ path, sup ]
    if File.exists?( tpok )
      pok = tpok
      break
    end
  end

  return if pok == nil

  bootfile = pok + "/boot.rb"
  envfile = pok + "/environment.rb"
  if File.exists?( bootfile ) && File.exists?( envfile )
    begin
      require bootfile
      require envfile
      require 'console_app'
      require 'console_with_helpers'
      VIM::command('let g:rubycomplete_rails_loaded = 1')
    rescue
      print "Error loading rails environment"
    end
  end
end

def get_rails_helpers
  allow_rails = VIM::evaluate('g:rubycomplete_rails')
  rails_loaded = VIM::evaluate('g:rubycomplete_rails_loaded')
  return [] if allow_rails != '1' || rails_loaded != '1'
  return RailsWords
end

def get_completions(base)
  load_requires
  load_rails

  input = VIM::Buffer.current.line
  cpos = VIM::Window.current.cursor[1] - 1
  input = input[0..cpos] if cpos != 0
  input += base

  rip = input.rindex(/\s/,cpos)
  if rip
    input = input[rip..input.length]
  end

  asn = /^.*(\+|\-|\*|=|\(|\[)=?(\s*[A-Za-z0-9_:@.-]*)(\s*(\{|\+|\-|\*|\%|\/)?\s*).*/
  if asn.match(input)
    input = $2
  end

  input.strip!
  message = nil
  receiver = nil
  candidates = []

  case input
    when /^(\/[^\/]*\/)\.([^.]*)$/ # Regexp
      receiver = $1
      message = Regexp.quote($2)
      candidates = Regexp.instance_methods(true)

    when /^([^\]]*\])\.([^.]*)$/ # Array
      receiver = $1
      message = Regexp.quote($2)
      candidates = Array.instance_methods(true)

    when /^([^\}]*\})\.([^.]*)$/ # Proc or Hash
      receiver = $1
      message = Regexp.quote($2)
      candidates = Proc.instance_methods(true) | Hash.instance_methods(true)

    when /^(:[^:.]*)$/ # Symbol
      if Symbol.respond_to?(:all_symbols)
        receiver = $1
        candidates = Symbol.all_symbols.collect{|s| s.id2name}
        candidates.delete_if { |c| c.match( /'/ ) }
      end

    when /^::([A-Z][^:\.\(]*)$/ # Absolute Constant or class methods
      receiver = $1
      candidates = Object.constants
      candidates.grep(/^#{receiver}/).collect{|e| "::" + e}

    when /^(((::)?[A-Z][^:.\(]*)+)::?([^:.]*)$/ # Constant or class methods
      receiver = $1
      message = Regexp.quote($4)
      begin
        candidates = eval("#{receiver}.constants | #{receiver}.methods")
      rescue Exception
        candidates = []
      end
      candidates.grep(/^#{message}/).collect{|e| receiver + "::" + e}

    when /^(:[^:.]+)\.([^.]*)$/ # Symbol
      receiver = $1
      message = Regexp.quote($2)
      candidates = Symbol.instance_methods(true)

    when /^([0-9_]+(\.[0-9_]+)?(e[0-9]+)?)\.([^.]*)$/ # Numeric
      receiver = $1
      message = Regexp.quote($4)
      begin
        candidates = eval(receiver).methods
      rescue Exception
        candidates
      end

    when /^(\$[^.]*)$/ #global
      candidates = global_variables.grep(Regexp.new(Regexp.quote($1)))

    when /^((\.?[^.]+)+)\.([^.]*)$/ # variable
      receiver = $1
      message = Regexp.quote($3)
      load_buffer_class( receiver )

      cv = eval("self.class.constants")
      vartype = get_var_type( receiver )
      if vartype != ''
        load_buffer_class( vartype )

        begin
          candidates = eval("#{vartype}.instance_methods")
        rescue Exception
          candidates = []
        end
      elsif (cv).include?(receiver)
        # foo.func and foo is local var.
        candidates = eval("#{receiver}.methods")
      elsif /^[A-Z]/ =~ receiver and /\./ !~ receiver
        # Foo::Bar.func
        begin
          candidates = eval("#{receiver}.methods")
        rescue Exception
          candidates = []
        end
      else
        # func1.func2
        candidates = []
        ObjectSpace.each_object(Module){|m|
          next if m.name != "IRB::Context" and
            /^(IRB|SLex|RubyLex|RubyToken)/ =~ m.name
          candidates.concat m.instance_methods(false)
        }
      end

    when /^\(?\s*[A-Za-z0-9:^@.%\/+*\(\)]+\.\.\.?[A-Za-z0-9:^@.%\/+*\(\)]+\s*\)?\.([^.]*)/
      message = $1
      candidates = Range.instance_methods(true)

    when /^\[(\s*[A-Za-z0-9:^@.%\/+*\(\)\[\]\{\}.\'\"],?)*\].([^.]*)/
      message = $2
      candidates = Array.instance_methods(true)

    when /^\.([^.]*)$/ # unknown(maybe String)
      message = Regexp.quote($1)
      candidates = String.instance_methods(true)

  else
    inclass = eval( VIM::evaluate("IsInClassDef()") )

    if inclass != nil
      classdef = "%s\n" % VIM::Buffer.current[ inclass.min ]
      found = /^\s*class\s*([A-Za-z0-9_-]*)(\s*<\s*([A-Za-z0-9_:-]*))?\s*\n$/.match( classdef )

      if found != nil
        receiver = $1
        message = input
        load_buffer_class( receiver )
        begin
          candidates = eval( "#{receiver}.instance_methods" )
          candidates += get_rails_helpers
        rescue Exception
          found = nil
        end
      end
    end

    if inclass == nil || found == nil
      candidates = eval("self.class.constants")
      candidates += get_buffer_classes
      message = receiver = input
    end
  end

  candidates.delete_if { |x| x == nil }
  candidates.uniq!
  candidates.sort!
  candidates = candidates.grep(/^#{Regexp.quote(message)}/) if message != nil

  outp = ""
  valid = (candidates-Object.instance_methods)

  rg = 0..valid.length
  rg.step(150) do |x|
    stpos = 0+x
    enpos = 150+x
    valid[stpos..enpos].each { |c| outp += "{'word':'%s','item':'%s'}," % [ c, c ] }
    outp.sub!(/,$/, '')

    VIM::command("call extend(g:rubycomplete_completions, [%s])" % outp)
    outp = ""
  end
end

# }}} ruby completion
RUBYEOF
endfunction

let g:rubycomplete_rails_loaded = 0

call s:DefRuby()
" vim:tw=78:sw=4:ts=8:et:ft=vim:norl:
