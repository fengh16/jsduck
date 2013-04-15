require "jsduck/tag/tag"
require "jsduck/doc/subproperties"
require "jsduck/render/property_signature"

module JsDuck::Tag
  class Cfg < Tag
    def initialize
      @pattern = "cfg"
      @tagname = :cfg
      @repeatable = true
      @member_type = {
        :name => :cfg,
        :category => :property_like,
        :title => "Config options",
        :toolbar_title => "Configs",
        :position => MEMBER_POS_CFG,
        :subsections => [
          {:title => "Required config options", :filter => {:required => true}},
          {:title => "Optional config options", :filter => {:required => false}, :default => true},
        ]
      }
    end

    # @cfg {Type} [name=default] (required) ...
    def parse_doc(p, pos)
      tag = p.standard_tag({:tagname => :cfg, :type => true, :name => true})
      tag[:optional] = false if parse_required(p)
      tag[:doc] = :multiline
      tag
    end

    def parse_required(p)
      p.hw.match(/\(required\)/i)
    end

    def process_doc(h, tags, pos)
      p = tags[0]
      h[:type] = p[:type]
      h[:default] = p[:default]
      h[:required] = true if p[:optional] == false

      # Documentation after the first @cfg is part of the top-level docs.
      h[:doc] += p[:doc]

      nested = JsDuck::Doc::Subproperties.nest(tags, pos)[0]
      h[:properties] = nested[:properties]
      h[:name] = nested[:name]
    end

    def to_html(cfg, cls)
      JsDuck::Render::PropertySignature.render(cfg)
    end
  end
end
