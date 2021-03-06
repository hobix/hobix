#
# = hobix/out/erb.rb
#
# Hobix processing of ERB templates.
#
# Copyright (c) 2003-2004 why the lucky stiff
#
# Written & maintained by why the lucky stiff <why@ruby-lang.org>
#
# This program is free software, released under a BSD license.
# See COPYING for details.
#
#--
# $Id$
#++
require 'hobix/base'
require 'erb'

module Hobix
module Out
class ERBError < StandardError; end
class ERB < Hobix::BaseOutput
    def initialize( weblog )
        @path = weblog.skel_path
    end
    def extension
        "erb"
    end
    def load( file_name, vars )
        @bind = binding
        vars.each do |k, v|
            k.untaint
            k_inspect = k.inspect.untaint
            eval( "#{ k } = vars[#{ k_inspect }]", @bind )
        end
        @relpath = File.dirname( file_name )
        @load_erb = import_erb( file_name )
        begin
            @load_erb.result( @bind )
        rescue Exception => e
            raise ERBError, "Error `#{ e.message }' in erb #{ file_name }."
        end
    end
    def expand( fname )
        if fname =~ /^\//
            File.join( @path, fname )
        else
            File.join( @relpath, fname )
        end
    end
    def import( fname, bindto = @bind )
        import_erb( expand( fname ) ).result( bindto )
    end
    def import_erb(fname)
        File.open(fname) do |fp| 
            src = fp.read.gsub( /<\+\s*([\w\.\/\\\-]+)\s*\+>/ ) do
                File.read( expand( $1 ) )
            end
            ::ERB.new( src, nil, nil, "_hobixout#{ rand( 9999999 ) }" )
        end
    end
end
end
end
