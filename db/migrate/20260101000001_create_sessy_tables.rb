# Creates the engine's tables. Types are kept portable (Postgres + SQLite):
# bigint primary/foreign keys and `t.json` (not jsonb). Table names carry the
# `sessy_` prefix the isolated engine expects for its models.
class CreateSessyTables < ActiveRecord::Migration[8.0]
  def change
    create_table :sessy_sources do |t|
      t.string :name, null: false
      t.string :token, null: false
      t.string :color, default: "blue"
      t.integer :retention_days
      t.timestamps
    end
    add_index :sessy_sources, :token, unique: true

    create_table :sessy_webhooks do |t|
      t.string :sns_message_id, null: false
      t.string :sns_type, null: false
      t.datetime :sns_timestamp, null: false
      t.json :raw_payload, default: {}, null: false
      t.datetime :processed_at
      t.timestamps
    end
    add_index :sessy_webhooks, :sns_message_id, unique: true
    add_index :sessy_webhooks, :processed_at

    create_table :sessy_messages do |t|
      t.string :ses_message_id, null: false
      t.string :source_email
      t.string :subject
      t.datetime :sent_at
      t.json :mail_metadata, default: {}
      t.integer :events_count, default: 0, null: false
      t.bigint :source_id
      t.timestamps
    end
    add_index :sessy_messages, :ses_message_id, unique: true
    add_index :sessy_messages, :source_email
    add_index :sessy_messages, :sent_at
    add_index :sessy_messages, :source_id
    add_foreign_key :sessy_messages, :sessy_sources, column: :source_id

    create_table :sessy_events do |t|
      t.string :ses_message_id, null: false
      t.string :event_type, null: false
      t.string :recipient_email, null: false
      t.string :bounce_type
      t.datetime :event_at, null: false
      t.json :event_data, default: {}
      t.json :raw_payload, default: {}
      t.bigint :message_id, null: false
      t.bigint :source_id
      t.bigint :webhook_id
      t.timestamps
    end
    add_index :sessy_events, [ :ses_message_id, :event_type, :recipient_email, :event_at ],
      unique: true, name: "index_sessy_events_on_dedup_key"
    add_index :sessy_events, :event_type
    add_index :sessy_events, :event_at
    add_index :sessy_events, :recipient_email
    add_index :sessy_events, :bounce_type
    add_index :sessy_events, :message_id
    add_index :sessy_events, :webhook_id
    add_index :sessy_events, [ :source_id, :event_at, :event_type ]
    add_index :sessy_events, [ :source_id, :event_type ]
    add_foreign_key :sessy_events, :sessy_messages, column: :message_id
    add_foreign_key :sessy_events, :sessy_sources, column: :source_id
    add_foreign_key :sessy_events, :sessy_webhooks, column: :webhook_id
  end
end
