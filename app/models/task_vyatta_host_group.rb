class TaskVyattaHostGroup < ActiveRecord::Base

  belongs_to :task
  belongs_to :vyatta_host_group

  default_scope select("`task_vyatta_host_groups`.*").joins(:vyatta_host_group).order(["`vyatta_host_groups`.`sort_order` ASC", "`vyatta_host_groups`.`name` ASC"])

  def includability
    return 0 if self.task.group_applicability == :exclusive
    return 1 if self.task.group_applicability == :inclusive
    return 2
  end

end
