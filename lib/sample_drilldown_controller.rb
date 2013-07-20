class SampleDrilldownController < DrilldownController

  default_fields %w{time receipt operation flight aircraft_registration stand volume_abbr volume_compensated payment_type supplier}
  target_class Transaction
  select "sum(CASE WHEN operation = 'FUELLING' THEN #{Volume::Sql::VOLUME} ELSE -#{Volume::Sql::VOLUME} END) as volume, sum(CASE WHEN operation = 'FUELLING' THEN #{Volume::Sql::VOLUME_COMPENSATED} ELSE -#{Volume::Sql::VOLUME_COMPENSATED} END) as volume_compensated, sum(CASE WHEN operation = 'CREDIT' THEN -1 ELSE 1 END) as count".freeze
  list_includes :operator, :stand, :supplier, :vehicle
  list_order 'transactions.created_at'

  field :aircraft_registration, :last_change_time => true
  field :aircraft_subtype, :attr_method => lambda { |transaction| transaction.aircraft_subtype_code }
  field :airfield_fee => {:excel_type => 'Number', :excel_style => 'ThreeDecimalNumberFormat'},
  field :authorization_reference => { :attr_method => lambda { |transaction| transaction.authorization.try(:authorization_reference) }},
  field :carnet_no => {},
  field :cash_price => {:excel_type => 'Number', :excel_style => 'ThreeDecimalNumberFormat'},
  field :co2_fee => {:excel_type => 'Number', :excel_style => 'ThreeDecimalNumberFormat'},
  field :comment => {},
#      :customer_name => {},
#      :defuelling_fee => {:excel_type => 'Number',
#        :excel_style => 'ThreeDecimalNumberFormat'},
#      :delay_codes => {},
#      :density => {:excel_type => 'Number',
#        :excel_style => 'StandardNumberFormat'},
#      :destination => {},
#      :dispatched =>  { :attr_method => lambda { |t| t.assignment.try(:created_at).try(:localtime).try(:strftime, '%H:%M') } },
#      :external => { :attr_method => lambda { |transaction| transaction.external_flight }},
#      :flight =>{ :attr_method => lambda { |transaction| transaction.flight_no } },
#      :fuel_request => { :attr_method => lambda { |t| t.assignment.try(:fuel_request)}, :last_change_time => true, :include => {:assignment => :order}},
#      :invoice_code => { :attr_method => lambda { |transaction| transaction.contract.try(:invoice_code)}},
#      :ofb => { :attr_method => lambda { |t| t.assignment.try(:order).try(:ofb).try(:localtime).try(:strftime, '%H:%M') } },
#      :onb => { :attr_method => lambda { |t| t.assignment.try(:order).try(:onb).try(:localtime).try(:strftime, '%H:%M') } },
#      :operation => {},
#      :operator_abbr => { :attr_method => lambda { |transaction| transaction.operator.try(:login) } },
#      :payment_type => {},
#      :product => {},
#      :ptd =>  { :attr_method =>lambda { |transaction| transaction.assignment.try(:order).try(:ptd).try(:localtime).try(:strftime, '%H:%M') } },
#      :receipt => { :attr_method => lambda { |transaction| transaction.receipt_code } },
#      # Not paid for, yet.
#      # :receptacle => {},
#      :receptacle_fee => {:excel_type => 'Number',
#        :excel_style => 'ThreeDecimalNumberFormat'},
#      :remarks => { :attr_method => lambda { |t| t.assignment.try(:order).try(:remarks) } },
#      :remote_fee => { :attr_method => lambda { |transaction| transaction.remote_fuelling_fee },
#        :excel_type => 'Number',
#        :excel_style => 'ThreeDecimalNumberFormat'},
#      :sta =>  { :attr_method =>lambda { |t| t.assignment.try(:order).try(:sta).try(:localtime).try(:strftime, '%H:%M') } },
#      :stand =>  { :attr_method =>lambda { |transaction| transaction.stand.try(:code) } },
#      :started => { :attr_method =>lambda { |t| t.assignment.try(:started_at).try(:localtime).try(:strftime, '%H:%M') } },
#      :std =>  { :attr_method =>lambda { |transaction| transaction.assignment.try(:order).try(:std).try(:localtime).try(:strftime, '%H:%M') } },
#      :supplier => { :attr_method => lambda { |transaction| transaction.supplier.try(:name) }},
#      :supplier_price => {:excel_type => 'Number',
#        :excel_style => 'ThreeDecimalNumberFormat'},
#      :temperature => {:excel_type => 'Number',
#        :excel_style => 'StandardNumberFormat'},
#      :time => {},
#      :vat_factor => {:excel_type => 'Number',
#        :excel_style => 'ThreeDecimalNumberFormat'},
#      :vehicle => { :attr_method => lambda { |transaction| transaction.vehicle.try(:name) }},
#      :volume_abbr => { :attr_method => lambda { |transaction| transaction.volume },
#        :excel_type => 'Number' },
#      :volume_compensated => {:excel_type => 'Number'},
#      :zero_fuelling_fee => {:excel_type => 'Number',
#        :excel_style => 'ThreeDecimalNumberFormat'},
#    }

    dimension :calendar_date, "DATE(transactions.created_at AT TIME ZONE 'CET0')", :interval => true
    dimension :comment, "CASE WHEN (transactions.comment is not null AND transactions.comment <> '') THEN 'Yes' ELSE 'No' END"
    dimension :corrected, "CASE WHEN meter1_start_volume_manual is not null OR meter1_stop_volume_manual is not null OR meter2_start_volume_manual is not null OR meter2_stop_volume_manual is not null THEN 'Yes' ELSE 'No' END"
    dimension :customer, 'COALESCE(customers.name, customer_name)', :includes => {:contract => :customer}
    dimension :day_of_month, "date_part('day', transactions.created_at AT TIME ZONE 'CET0')"
    dimension :day_of_week, "CASE WHEN date_part('dow', transactions.created_at AT TIME ZONE 'CET0') = 0 THEN 7 ELSE date_part('dow', transactions.created_at AT TIME ZONE 'CET0') END",
              :label_method => lambda { |day_no| Date::DAYNAMES[day_no.to_i % 7] }
    dimension :delay_codes, "transactions.delay_codes IS NOT NULL AND (transactions.delay_codes LIKE '%GF36%')",
              :label_method => lambda { |val| val == 't' || val == 'true' ? 'With' : 'Without' },
              :legal_values => lambda { | val | [['With', 't'], ['Without', 'f']]}
    dimension :destination, "CASE WHEN external_flight = 't' THEN '#{t(:international)}' ELSE '#{t(:domestic)}' END"
    dimension :hour_of_day, "date_part('hour', transactions.created_at AT TIME ZONE 'CET0')"
    dimension :manual, "CASE WHEN receipt_no < #{Transactional::MANUAL_RECEIPT_NO_LIMIT} THEN 'Automatic' ELSE 'Manual' END"
    dimension :month, "date_part('month', transactions.created_at AT TIME ZONE 'CET0')",
              :label_method => lambda { |month_no| Date::MONTHNAMES[month_no.to_i] }
    dimension :operation, 'operation'
    dimension :operator, 'users.login', :includes => :operator
    dimension :payment_type, 'payment_type'
    dimension :pit, 'pits.code', :includes => :pit
    # Not paid for yet: 4h
    # dimension :receptacle, 'receptacle'
    dimension :stand, 'stands.code', :includes => :stand
    dimension :supplier, 'suppliers.name', :includes => :supplier
    dimension :terminal, "CASE WHEN stands.code like '3__%' THEN 'GA' WHEN stands.code like 'M%' THEN 'Military' WHEN stands.code like 'PAD' THEN 'PAD' ELSE 'Terminal 1' END",
              :includes => :stand, :label_method => lambda { |val| val }
    dimension :vehicle, 'vehicles.name', :includes => :vehicle
    dimension :week, "date_part('week', transactions.created_at AT TIME ZONE 'CET0')"
    dimension :year, "date_part('year', transactions.created_at AT TIME ZONE 'CET0')"
    dimension :zero_fuelling, "CASE WHEN zero_fuelling_fee is not null THEN 'Zero' ELSE 'Non-zero' END"

end
