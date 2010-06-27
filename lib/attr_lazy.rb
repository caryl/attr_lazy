module AttrLazy

  def self.included(base_class)
    base_class.extend(ClassMethods)
  end

  module ClassMethods
    def attr_lazy(*columns)
      cattr_accessor :attr_lazy_columns
      self.attr_lazy_columns = columns

      include AttrLazy::InstanceMethods

      columns.each do |col|
        class_eval("def #{col}; fetch_lazy_attribute :#{col}; end", __FILE__, __LINE__)
      end
      
      #construct_finder_sql
      def self.construct_finder_sql_with_attr_lazy(options)
        options = {:select => select_column_list}.merge(options) unless options[:limit] == 1
        construct_finder_sql_without_attr_lazy(options)
      end

      def self.select_column_list
        column_names.collect do |c|
          "#{quoted_table_name}.#{connection.quote_column_name(c)}" unless attr_lazy_columns.include?(c.to_sym)
        end.compact.join ','
      end
      
      class << self
        alias_method_chain :construct_finder_sql, :attr_lazy
      end
    end
  end

  module InstanceMethods
    def fetch_lazy_attribute(att)
      @lazy_attribute_values ||= {}
      if attribute_names.include?(att.to_s)
        read_attribute att
      else
        @lazy_attribute_values[att] ||= self.class.find(id, :select => att)[att]
      end
    end
  end
end

