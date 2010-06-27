ActiveRecord::Schema.define(:version => 0) do
	create_table :articles, :force => true do |t|
	  t.string :name
	  t.text :body
    t.integer :channel_id
	end
	create_table :channels, :force => true do |t|
	  t.string :name
	end

end
