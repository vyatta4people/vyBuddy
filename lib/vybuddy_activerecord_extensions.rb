module VyBuddyActiveRecordExtensions

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    attr_accessor :reorganize_with_persistent_order_message

    def reorganize_with_persistent_order(moved_record, replaced_record, scope_attribute = nil)
      if scope_attribute
        moved_scope_value     = moved_record.read_attribute(scope_attribute)
        replaced_scope_value  = replaced_record.read_attribute(scope_attribute)
        all_records           = self.order(["`sort_order` ASC"]).where(["`#{scope_attribute}` = ?", moved_scope_value])
      else
        all_records = self.order(["`sort_order` ASC"]).all
      end

      success               = false
      max_sort_order        = all_records.length - 1
      if scope_attribute
        if moved_scope_value == replaced_scope_value
          moved_sort_order  = replaced_record.sort_order
        elsif moved_scope_value > replaced_scope_value
          moved_sort_order  = 0
        elsif moved_scope_value < replaced_scope_value
          moved_sort_order  = max_sort_order
        end
      else
        moved_sort_order    = replaced_record.sort_order
      end

      all_reorganized_records = Array.new
      sort_order              = 0
      while sort_order <= max_sort_order
        if sort_order != moved_sort_order
          record = all_records.shift
          if record != moved_record
            all_reorganized_records[sort_order]             = record
            all_reorganized_records[sort_order].sort_order  = sort_order
          else
            next
          end
        else
          all_reorganized_records[sort_order]               = moved_record
          all_reorganized_records[sort_order].sort_order    = sort_order
        end
        sort_order += 1
      end

      begin
        self.transaction do
          all_reorganized_records.each { |record| record.save }
        end
      rescue => e
        self.reorganize_with_persistent_order_message = e.message
      else
        success                                       = true
        self.reorganize_with_persistent_order_message = "#{self.name} #{moved_record.id}: #{moved_record.sort_order} => #{moved_sort_order}"
      end

      return success
    end

  end

end

ActiveRecord::Base.send(:include, VyBuddyActiveRecordExtensions)