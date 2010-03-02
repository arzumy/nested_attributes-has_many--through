ActiveRecord::AutosaveAssociation::ClassMethods.module_eval do
  # Adds a validate and save callback for the association as specified by
  # the +reflection+.
  #
  # For performance reasons, we don't check whether to validate at runtime,
  # but instead only define the method and callback when needed. However,
  # this can change, for instance, when using nested attributes. Since we
  # don't want the callbacks to get defined multiple times, there are
  # guards that check if the save or validation methods have already been
  # defined before actually defining them.
  def add_autosave_association_callbacks(reflection)
    save_method = "autosave_associated_records_for_#{reflection.name}"
    validation_method = "validate_associated_records_for_#{reflection.name}"
    force_validation = (reflection.options[:validate] == true || reflection.options[:autosave] == true)

    case reflection.macro
    when :has_many, :has_and_belongs_to_many
      unless method_defined?(save_method)
        before_save :before_save_collection_association

        define_method(save_method) { save_collection_association(reflection) }
        # Doesn't use after_save as that would save associations added in after_create/after_update twice
        after_create save_method
        after_update save_method
      end

      if !method_defined?(validation_method) &&
          (force_validation || (reflection.macro == :has_many && reflection.options[:validate] != false))
        define_method(validation_method) { validate_collection_association(reflection) }
        validate validation_method
      end
    else
      unless method_defined?(save_method)
        case reflection.macro
        when :has_one
          define_method(save_method) { save_has_one_association(reflection) }
          after_save save_method
        when :belongs_to
          define_method(save_method) { save_belongs_to_association(reflection) }
          before_save save_method
        end
      end

      if !method_defined?(validation_method) && force_validation
        define_method(validation_method) { validate_single_association(reflection) }
        validate validation_method
      end
    end
  end
end

ActiveRecord::NestedAttributes::ClassMethods.module_eval do
  def accepts_nested_attributes_for(*attr_names)
    options = { :allow_destroy => false }
    options.update(attr_names.extract_options!)
    options.assert_valid_keys(:allow_destroy, :reject_if, :limit)

    attr_names.each do |association_name|
      if reflection = reflect_on_association(association_name)
        type = case reflection.macro
        when :has_one, :belongs_to
          :one_to_one
        when :has_many, :has_and_belongs_to_many
          :collection
        end

        reflection.options[:autosave] = true
        add_autosave_association_callbacks(reflection)
        self.nested_attributes_options[association_name.to_sym] = options

        # def pirate_attributes=(attributes)
        #   assign_nested_attributes_for_one_to_one_association(:pirate, attributes, false)
        # end
        class_eval %{
          def #{association_name}_attributes=(attributes)
            assign_nested_attributes_for_#{type}_association(:#{association_name}, attributes)
          end
        }, __FILE__, __LINE__
      else
        raise ArgumentError, "No association found for name `#{association_name}'. Has it been defined yet?"
      end
    end
  end
end