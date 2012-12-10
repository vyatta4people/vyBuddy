module VyBuddyActiveRecordExtensions

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    attr_accessor :reorder_records_message
    def reorder_records(records)
      ordered_records = Array.new
      sort_order      = 0
      records.each do |record|
        ordered_records << record
        ordered_records[sort_order].sort_order  = sort_order
        sort_order                              += 1
      end
      begin
        self.transaction do
          ordered_records.each { |record| record.save }
        end
      rescue => e
        self.reorder_records_message = e.message
        return nil
      else
        self.reorder_records_message = ""
        return ordered_records
      end
    end

    def get_next_sort_order(scope_attribute = nil, scope_attribute_value = nil)
      sort_order = 0
      if scope_attribute
        last_record = self.order(["`sort_order` ASC"]).where(["`#{scope_attribute}` = ?", scope_attribute_value]).last
      else
        last_record = self.order(["`sort_order` ASC"]).last
      end
      if last_record
        sort_order = last_record.sort_order + 1
      end
      return sort_order
    end

    def get_moved_sort_order(moved_sort_order, replaced_sort_order, position)
      if position == :after
        if moved_sort_order > replaced_sort_order
          return replaced_sort_order + 1
        else
          return replaced_sort_order
        end
      else
        if moved_sort_order < replaced_sort_order
          return replaced_sort_order - 1
        else
          return replaced_sort_order
        end
      end
    end

    attr_accessor :reorganize_with_persistent_order_message
    def reorganize_with_persistent_order(moved_record, replaced_record, position, scope_attribute = nil)
      if moved_record.class.to_s != replaced_record.class.to_s
        self.reorganize_with_persistent_order_message = "Different classes for moved and replaced records: #{moved_record.class.to_s} and #{replaced_record.class.to_s}"
        return nil
      end

      if scope_attribute
        moved_scope_value         = moved_record.read_attribute(scope_attribute)
        replaced_scope_value      = replaced_record.read_attribute(scope_attribute)
        if !scope_attribute.to_s.match(/_id$/) or moved_scope_value.class.to_s != "Fixnum" or replaced_scope_value.class.to_s != "Fixnum"
          self.reorganize_with_persistent_order_message = "Inappropriate scope attribute: #{scope_attribute.to_s} => #{moved_scope_value.class.to_s} / #{replaced_scope_value.class.to_s}"
          return nil
        end
        scope_class               = eval(scope_attribute.to_s.sub(/_id$/, '').camelcase)
        moved_scope_record        = scope_class.find(moved_scope_value)
        replaced_scope_record     = scope_class.find(replaced_scope_value)
        if moved_scope_record.attribute_present?(:sort_order)
          moved_scope_sort_order  = moved_scope_record.sort_order
        else
          moved_scope_sort_order  = moved_scope_value
        end
        if replaced_scope_record.attribute_present?(:sort_order)
          replaced_scope_sort_order  = replaced_scope_record.sort_order
        else
          replaced_scope_sort_order  = replaced_scope_value
        end
        all_records               = self.order(["`sort_order` ASC"]).where(["`#{scope_attribute}` = ?", moved_scope_value])
      else
        all_records               = self.order(["`sort_order` ASC"]).all
      end

      max_sort_order = all_records.length - 1
      if scope_attribute
        if moved_scope_sort_order == replaced_scope_sort_order
          moved_sort_order = get_moved_sort_order(moved_record.sort_order, replaced_record.sort_order, position)
        elsif moved_scope_sort_order > replaced_scope_sort_order
          moved_sort_order  = 0
        elsif moved_scope_sort_order < replaced_scope_sort_order
          moved_sort_order  = max_sort_order
        end
      else
        moved_sort_order = get_moved_sort_order(moved_record.sort_order, replaced_record.sort_order, position)
      end

      all_ordered_records   = self.reorder_records(all_records)
      if !all_ordered_records
        self.reorganize_with_persistent_order_message = "No records reordered (#{self.to_s}: #{self.reorder_records_message})"
        return false
      end

      all_reorganized_records = Array.new
      sort_order              = 0
      while sort_order <= max_sort_order
        if sort_order != moved_sort_order
          record = all_ordered_records.shift
          if record != moved_record
            all_reorganized_records << record
            all_reorganized_records.last.sort_order = sort_order
          else
            next
          end
        else
          all_reorganized_records << moved_record
          all_reorganized_records.last.sort_order = sort_order
        end
        sort_order += 1
      end

      begin
        self.transaction do
          all_reorganized_records.each { |r| r.save }
        end
      rescue => e
        self.reorganize_with_persistent_order_message = e.message
        return false
      else
        self.reorganize_with_persistent_order_message = "[#{self.name}] #{moved_record.id}: #{moved_record.sort_order} => #{moved_sort_order}"
        return true
      end

      self.reorganize_with_persistent_order_message = "Unknown error"
      return nil
    end

  end

end

ActiveRecord::Base.send(:include, VyBuddyActiveRecordExtensions)
