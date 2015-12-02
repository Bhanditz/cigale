
module Cigale::Property
  require "cigale/property/inject"
  require "cigale/property/least-load"
  require "cigale/property/delivery-pipeline"
  require "cigale/property/ownership"
  require "cigale/property/builds-chain-fingerprinter"
  require "cigale/property/slave-utilization"
  require "cigale/property/batch-tasks"

  def property_classes
    @property_classes ||= {
      "inject" => "EnvInjectJobProperty",
      "least-load" => "org.bstick12.jenkinsci.plugins.leastload.LeastLoadDisabledProperty",
      "delivery-pipeline" => "se.diabol.jenkins.pipeline.PipelineProperty",
      "ownership" => "com.synopsys.arc.jenkins.plugins.ownership.jobs.JobOwnerJobProperty",
      "builds-chain-fingerprinter" => "org.jenkinsci.plugins.buildschainfingerprinter.AutomaticFingerprintJobProperty",
      "slave-utilization" => "com.suryagaddipati.jenkins.SlaveUtilizationProperty"
    }
  end

  def translate_properties (xml, props)
    if (props || []).size == 0
      return xml.properties
    end

    xml.properties do
      for p in props
        case p
        when "delivery-pipeline"
          xml.tag! property_classes[p] do
            xml.stageName
            xml.taskName
          end
          next
        when "zeromq-event"
          xml.tag! "org.jenkinsci.plugins.ZMQEventPublisher.HudsonNotificationProperty" do
            xml.enabled true
          end
          next
        end

        ptype, pdef = first_pair(p)
        clazz = property_classes[ptype]

        unless clazz
          raise "Unknown property type: #{ptype}"
        end

        xml.tag! clazz do
          self.send "translate_#{underize(ptype)}_property", xml, pdef
        end
      end
    end
  end

  def boolp (val, default)
    if val.nil?
      default
    else
      val
    end
  end
end
