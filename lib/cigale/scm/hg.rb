
module Cigale::SCM::Hg
  def translate_hg_scm (xml, sdef)
    xml.source sdef["url"]
    if cid = sdef["credentials-id"]
      xml.credentialsId cid
    end
    xml.revisionType "BRANCH"
    xml.revision sdef["revision"] || "default"
    if sub = sdef["subdir"]
      xml.subdir sub
    end
    xml.clean sdef["clean"] || false
    if sdef["modules"]
      xml.modules sdef["modules"].join " "
    else
      xml.modules
    end
    xml.disableChangeLog sdef["disable-changelog"] || false

    if browser = sdef["browser"]
      bclass = hg_browser_classes[browser] or raise "Unknown hg browser type #{browser}"
      xml.browser :class => bclass do
        if val = sdef["browser-url"]
          xml.url val
        end
      end
    end
  end

  def hg_browser_classes
    @hg_browser_classes ||= {
      "hgweb" => "hudson.plugins.mercurial.browser.HgWeb",
    }
  end
end