module Objectify
    private
    def self.included(base)
        base.class_eval do
            attr_reader :after_initialize #- This method should be defined since after_initialize is used as macro
        end
        
        #--- Bind active record callbacks (in instance level) to process object attributes
        base.after_initialize :load_object_attributes
        base.before_save :save_object_attributes

        #--- Method for declaratively calling from a model to create an object attribute
        private
        def base.object_attribute(attribute_name, default_class, column_name = (attribute_name.to_s + "_object").to_sym)
            #--- Store the attribute info in an array
            @object_attributes ||= Array.new
            @object_attributes.push({:name => attribute_name, :default_class => default_class, :column => column_name})

            #--- Create accessor for the object attribute in the instance
            attr_accessor attribute_name.to_sym

            #--- Method to expose the object attributes list to instance methods
            private
            def self.object_attributes
                return @object_attributes
            end
        end
    end
    
    private
    def load_object_attributes
        return if not self.class.respond_to?(:object_attributes) #- Return if no object attribute was not defined
        
        @object_attributes = self.class.object_attributes
        
        @object_attributes.each do |attr|
            column_value = read_attribute(attr[:column])
            if column_value.nil?
                instance_variable_set("@" + attr[:name].to_s, eval("#{attr[:default_class]}.new")) 
            else
                instance_variable_set("@" + attr[:name].to_s, Marshal::load(read_attribute(attr[:column])))
            end
        end
    end
    
    private
    def save_object_attributes        
        return if not self.class.respond_to?(:object_attributes) #- Return if no object attribute was not defined
        
        @object_attributes.each do |attr|
            current_value = eval("@" + attr[:name].to_s)
            
            #--- Check if this is a new record that is going to be saved and the column has been given a value specifically. This happens during cloning
            if new_record? and not read_attribute(attr[:column]).nil?
                next #- Dont do anything in this loop as the column has been given a value specifically
            end
            
            #--- Check if the initial value has been changed before saving
            if not current_value.nil?
                if current_value == eval("#{attr[:default_class]}.new")
                    current_value = nil
                elsif eval("#{attr[:default_class]}.respond_to?(:changed)") and not current_value.changed?
                    current_value = nil
                elsif Marshal::dump(current_value) == Marshal::dump(eval("#{attr[:default_class]}.new"))
                    current_value = nil
                end
            end
            
            if current_value.nil?
                write_attribute(attr[:column], nil)
            else
                write_attribute(attr[:column], Marshal::dump(current_value))
            end
        end
    end
end