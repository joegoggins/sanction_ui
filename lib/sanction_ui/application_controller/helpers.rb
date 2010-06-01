module SanctionUi
  module ApplicationController
    module Helpers
      def self.included(controller_class)
        controller_class.class_eval do
          def set_access_denied_flash(perm_or_role, over_class_or_inst=nil)
            flash[:sui_denied_role_def_or_perm_name] = perm_or_role
            if over_class_or_inst.class == Class
              flash[:sui_denied_over_type] = over_class_or_inst
            elsif (not over_class_or_inst.blank?)
              flash[:sui_denied_over_type] = over_class_or_inst.class
              flash[:sui_denied_over_instance] = over_class_or_inst
            end
          end
          # RETURNS true if denied and is redirecting.
          # Usage in controller action:
          #   return false if redirect_to_access_denied_if_cannot(:can_index, Thing)
          def redirect_to_access_denied_if_cannot(permission_or_role, permissionable_class_or_instance=nil)
            if permissionable_class_or_instance.blank?
              permissions_check_method = :has?                        # if SanctionUi.assume_eager_loaded_principal_roles
                                                                      #   permissions_check_method = :eager_has?
                                                                      # else
                                                                      #   permissions_check_method = :has?
                                                                      # end
              unless current_principal.send(permissions_check_method, permission_or_role)
                set_access_denied_flash(permission_or_role)
                redirect_to(sanction_ui_access_denied_path) and return true
              end
            else
              if permissionable_class_or_instance.respond_to?(:new_record?) && permissionable_class_or_instance.new_record? 
                raise "sanction_ui error: You called this method wrongly, for records that haven't been saved use, will be like:
                  redirect_to_access_denied_if_cannot(:can_jump, Thing) 
                  instead of
                  redirect_to_access_denied_if_cannot(:can_jump, @a_new_thing)
                "
              end
              check_result = current_principal.has(permission_or_role).over?(permissionable_class_or_instance)
              # if SanctionUi.assume_eager_loaded_principal_roles
              #   check_result = current_principal.eager_has_over?(permission_or_role,permissionable_class_or_instance)
              # else
              #   check_result = current_principal.has(permission_or_role).over?(permissionable_class_or_instance)
              # end
              unless check_result 
                set_access_denied_flash(permission_or_role, permissionable_class_or_instance)
                redirect_to(sanction_ui_access_denied_path) and return true
              end
            end
            return false
          end
        end
      end
    end
  end
end