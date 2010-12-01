

class Rapuncel::Hash
  
end

class Hash
  #Hash will be translated into an XML-RPC "struct" object

  def to_xml_rpc b = Rapuncel.get_builder

    b.struct do |b|
      self.each_pair do |key, value|

        #warn "The key #{key.to_s} is a #{key.class.to_s}, which is neither a symbol nor a string. It will be converted using to_s" unless key.is_a?(String) || key.is_a?(Symbol)

        b.member do |b|

          b.name key.to_s
          b.value do |b|
            value.to_xml_rpc b
          end
        end
      end
    end
    
    b.to_xml
  end
  
  def self.from_xml_rpc xml_node
    #warn "The given xml_node is a #{xml_node.name}, not a 'struct'. Continuing at your risk" unless ['struct'].include? xml_node.name
    
    keys_and_values = xml_node.element_children #xpath('./member')
    
    hash = new
    keys_and_values.each do |kv|
      key = kv.first_element_child.text.to_sym
      
      value = Object.from_xml_rpc kv.last_element_child.first_element_child
      hash[key] = value      
    end
    hash
  end  
end
