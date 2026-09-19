# frozen_string_literal: true

# Demo HR user + N employees (default 10_000). Override with SEED_COUNT=100 for smoke runs.
# Uses insert_all in batches of 1000. Lightweight name generator (no Faker).

COUNTRIES = %w[US IN GB DE SG AU].freeze
CURRENCIES = { "US" => "USD", "IN" => "INR", "GB" => "GBP", "DE" => "EUR", "SG" => "SGD", "AU" => "AUD" }.freeze
DEPARTMENTS = %w[Engineering Sales HR Finance Operations Support].freeze

FIRST_NAMES = %w[
  Emma Olivia Noah Liam Ava Sophia Mia James Benjamin Lucas Amelia Harper
  Evelyn Alexander Henry Mia Oliver Elijah William Sophia Isabella Charlotte
  Aria Rohit Priya Ananya Arjun Vikram Mei Wei Hiro Kenji Fatima Yusuf
  Chloe Nathan Grace Leo Zoe Nina Omar Sara Diego Sofia Elena Marco
].uniq.freeze

LAST_NAMES = %w[
  Smith Johnson Williams Brown Jones Garcia Miller Davis Rodriguez Martinez
  Hernandez Lopez Gonzalez Wilson Anderson Thomas Taylor Moore Jackson Martin
  Patel Sharma Gupta Singh Kim Park Chen Wang Li Tanaka Suzuki Mueller
  Schmidt Fischer Weber Meyer Santos Silva Costa Alves Dubois Bernard
].freeze

def random_name(rng)
  [FIRST_NAMES[rng.rand(FIRST_NAMES.length)], LAST_NAMES[rng.rand(LAST_NAMES.length)]]
end

puts "Seeding HR user..."
User.find_or_create_by!(email: "hr@acme.com") do |u|
  u.password = "password123"
  u.role = "hr"
end

count = ENV.fetch("SEED_COUNT", "10000").to_i
if Employee.count >= count && ENV["FORCE_SEED"] != "1"
  puts "Already have #{Employee.count} employees (>= #{count}). Set FORCE_SEED=1 to reseed."
  exit
end

if ENV["FORCE_SEED"] == "1"
  puts "FORCE_SEED=1 — clearing employees/salaries..."
  Salary.delete_all
  Employee.delete_all
end

puts "Seeding #{count} employees..."
rng = Random.new(42)
batch_size = 1000
now = Time.current
created = 0

(0...count).each_slice(batch_size) do |slice|
  employees = slice.map do |i|
    country = COUNTRIES[i % COUNTRIES.length]
    first, last = random_name(rng)
    code = format("ACM%06d", i + 1)
    hire = Date.new(2015, 1, 1) + rng.rand(0..3650)
    {
      employee_code: code,
      first_name: first,
      last_name: last,
      email: "#{first.downcase}.#{last.downcase}.#{i + 1}@acme.example",
      country: country,
      department: DEPARTMENTS[i % DEPARTMENTS.length],
      hire_date: hire,
      status: rng.rand < 0.92 ? "active" : "inactive",
      created_at: now,
      updated_at: now
    }
  end

  Employee.insert_all(employees)
  created += employees.size
  print "\r  employees: #{created}/#{count}"
end
puts

puts "Seeding salaries (1–3 rows per employee)..."
# Map codes to ids
id_by_code = Employee.pluck(:employee_code, :id).to_h
hire_by_id = Employee.pluck(:id, :hire_date).to_h
country_by_id = Employee.pluck(:id, :country).to_h

salary_rows = []
flush = lambda do
  return if salary_rows.empty?
  Salary.insert_all(salary_rows)
  salary_rows.clear
end

Employee.pluck(:employee_code).each_with_index do |code, idx|
  emp_id = id_by_code[code]
  country = country_by_id[emp_id]
  currency = CURRENCIES[country]
  hire = hire_by_id[emp_id]
  n = 1 + rng.rand(3) # 1..3

  # Base annual salary in major units, stored as cents
  base = case country
         when "IN" then 400_000 + rng.rand(1_200_000)
         when "US", "GB", "DE", "AU", "SG" then 45_000 + rng.rand(120_000)
         else 50_000 + rng.rand(80_000)
         end

  dates = n.times.map { |k| hire + (k * (180 + rng.rand(400))) }.sort
  dates.each_with_index do |from, k|
    amount = ((base * (1 + k * 0.08)) * 100).to_i
    effective_to = k == n - 1 ? nil : dates[k + 1] - 1
    salary_rows << {
      employee_id: emp_id,
      amount_cents: amount,
      currency: currency,
      effective_from: from,
      effective_to: effective_to,
      reason: k.zero? ? "Initial" : "Adjustment",
      created_at: now,
      updated_at: now
    }
  end

  flush.call if salary_rows.size >= 2000
  print "\r  salaries progress: #{idx + 1}/#{count}" if ((idx + 1) % 500).zero? || idx + 1 == count
end
flush.call
puts
puts "Done. Users=#{User.count} Employees=#{Employee.count} Salaries=#{Salary.count}"
