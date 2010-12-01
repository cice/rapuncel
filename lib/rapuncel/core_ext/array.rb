
require 'nokogiri'

class Array

  def to_xml_rpc b = Rapuncel.get_builder

    b.array do |b|
      b.data do |b|
        each do |array_entry|
          b.value do |b|
            array_entry.to_xml_rpc b
          end
        end
      end
    end
    
    b.to_xml
  end
  
  
  def self.from_xml_rpc xml_node
    #warn "Warning: This is not an array-node (It is a(n) #{xml_node.name}.). Parsing may go wrong. Continuing at your risk" unless ['array'].include? xml_node.name.downcase
    
    
    values = xml_node.first_element_child.element_children #xpath('./data/value/*')
    
    values.map do |value|
      Object.from_xml_rpc value.first_element_child
    end    
  end
end
