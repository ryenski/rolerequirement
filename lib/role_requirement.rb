# RoleRequirement
module RoleRequirement
  def self.included(controller)
    controller.extend(ClassMethods)
    controller.before_filter(:ensure_allowed_role)
  end
  
  module ClassMethods
    def require_role(roles, *actions)
      write_inheritable_array(:require_role, [roles].flatten)
      write_inheritable_array(:require_role_actions, actions)
    end
  end
  
  protected
    def has_role?
      (self.class.read_inheritable_attribute(:require_role) || []).include?(current_user.role.name.downcase.to_sym)
    end
    
    def action_protected?
      (self.class.read_inheritable_attribute(:require_role_actions) || []).include?(action_name.to_sym)
    end
  
  private
    def ensure_allowed_role
      if action_protected?
        return true if has_role?
        
        this_action = case action_name
        when "new"
          "create"
        when "destroy"
          "delete"
        else
          action_name
        end
        
        flash[:error] = "#{current_user.role.name.pluralize} are not authorized to #{this_action} #{controller_name}."
        redirect_to :back and return false
      end
    end
end