module SanctionUi
  module ApplicationController
    module Helpers
      def self.included(controller_class)
        controller_class.class_eval do
          # RETURNS true if denied and is redirecting.
          #
          def redirect_to_access_denied_if_cannot(permission_or_role, permissionable_class_or_instance=nil)
            if permissionable_class_or_instance.blank?
              unless current_principal.has?(permission_or_role)
                redirect_to(sanction_ui_access_denied_path(permission_or_role)) and return true
              end
            else
              if permissionable_class_or_instance.respond_to?(:new_record?) && permissionable_class_or_instance.new_record? 
                raise "sanction_ui error: You called this method wrongly, for records that haven't been saved use, will be like:
                  redirect_to_access_denied_if_cannot(:can_jump, Thing) 
                  instead of
                  redirect_to_access_denied_if_cannot(:can_jump, @a_new_thing)
                "
              end
              unless current_principal.has(permission_or_role).over?(permissionable_class_or_instance)
                if permissionable_class_or_instance.class == Class
                  redirect_to(sanction_ui_access_denied_over_path(permission_or_role, permissionable_class_or_instance)) and return true
                else
                  redirect_to(sanction_ui_access_denied_over_path(permission_or_role, permissionable_class_or_instance.class.to_s, permissionable_class_or_instance)) and return true
                end
              end
            end
            return false
          end
        end
      end
    end
  end
end