require 'handlebars/source'
require 'mini_racer'
require 'securerandom'

module Smolbars
  class Context
    def initialize(**kwargs)
      @js = MiniRacer::Context.new(kwargs)
      @js.load(Handlebars::Source.bundled_path)
    end

    # Note that this is a hacky JS expression builder. We cannot pass JS AST in to mini_racer so we have to
    # hope the template passed in does not form invalid Ruby. So don't use templates with backtick characters without
    # manually escaping them
    def compile(template)
      handle = fn_handle
      invocation = %Q{var #{handle} = Handlebars.compile(`#{template.gsub('`', "\`")}`);}
      @js.eval(invocation)
      ::Smolbars::Template.new(self, handle)
    end

    def eval(*args)
      @js.eval(*args)
    end

    def load_pattern(pattern)
      Dir[pattern].each{ |path| load(path) }
    end

    def load(path)
      @js.load(path)
    end

    private

    def fn_handle
      "js_fn_#{SecureRandom.hex}"
    end
  end
end
