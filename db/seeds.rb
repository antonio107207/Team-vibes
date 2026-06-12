users_data = [
  { name: "Антон Д.", email: "anton@brincdrones.com", position: "Backend Developer", bio: "Ruby, Rails, PostgreSQL. Люблю чистий код і гарну каву." },
  { name: "Олена К.", email: "olena@brincdrones.com", position: "Frontend Developer", bio: "React, TypeScript. Завжди слухаю музику за роботою." },
  { name: "Дмитро В.", email: "dmytro@brincdrones.com", position: "DevOps Engineer", bio: "Kubernetes, Docker. Геймер у вільний час." },
  { name: "Марія С.", email: "maria@brincdrones.com", position: "Product Designer", bio: "Figma, UX. Мій кіт Барсик завжди поруч." },
  { name: "Тарас П.", email: "taras@brincdrones.com", position: "QA Engineer", bio: "Автоматизація тестів і книги про продуктивність." }
]

users = users_data.map do |data|
  User.find_or_create_by!(email: data[:email]) do |u|
    u.name = data[:name]
    u.password = "password123"
    u.position = data[:position]
    u.bio = data[:bio]
    u.provider = "seed"
    u.uid = data[:email]
  end
end

entries_data = [
  { user: users[0], category: :movies, title: "Dune: Part Two", description: "Вражаючий візуал і глибока філософія. Одна з кращих sci-fi епопей.", rating: 5 },
  { user: users[0], category: :music, title: "Radiohead — OK Computer", description: "Класика, яка не старіє. Слухаю вже 10 років.", rating: 5 },
  { user: users[1], category: :music, title: "Tame Impala — Currents", description: "Ідеально для роботи у фоновому режимі.", rating: 4 },
  { user: users[1], category: :games, title: "Hollow Knight", description: "Геніальний metroidvania. Хочу пройти Silksong як вийде.", rating: 5 },
  { user: users[2], category: :games, title: "The Witcher 3", description: "Найкраща RPG яку я грав. 300+ годин і не шкодую.", rating: 5 },
  { user: users[2], category: :books, title: "The Phoenix Project", description: "Обов'язково для будь-якого DevOps. Читається як детектив.", rating: 5 },
  { user: users[3], category: :pets, title: "Барсик — мій британець", description: "3 роки. Любить сидіти на клавіатурі поки я працюю 🐱", rating: nil },
  { user: users[3], category: :movies, title: "Everything Everywhere All at Once", description: "Зовні схоже на нісенітницю, але це геніально.", rating: 5 },
  { user: users[4], category: :books, title: "Deep Work — Cal Newport", description: "Змінила підхід до продуктивності. Раджу всім.", rating: 4 },
  { user: users[4], category: :sports, title: "Бігаю щоранку", description: "5км щодня вже рік. Найкраще рішення для ментального здоров'я.", rating: nil }
]

entries_data.each do |data|
  HobbyEntry.find_or_create_by!(user: data[:user], title: data[:title]) do |e|
    e.category = data[:category]
    e.description = data[:description]
    e.rating = data[:rating]
  end
end

entries = HobbyEntry.all.to_a

entries.each_with_index do |entry, i|
  liker = users[(i + 1) % users.size]
  Like.find_or_create_by!(user: liker, likeable: entry)
  liker2 = users[(i + 2) % users.size]
  Like.find_or_create_by!(user: liker2, likeable: entry) rescue nil
end

Comment.find_or_create_by!(user: users[1], commentable: entries[0], body: "Теж дивилась! Ханс Циммер як завжди 🔥")
Comment.find_or_create_by!(user: users[2], commentable: entries[0], body: "Чаклун краще 😄")
Comment.find_or_create_by!(user: users[0], commentable: entries[2], body: "Слухав на петлі весь тиждень")
Comment.find_or_create_by!(user: users[3], commentable: entries[5], body: "Читала! Gene Kim — геній")

puts "✅ Seeds завантажено: #{User.count} users, #{HobbyEntry.count} entries, #{Like.count} likes, #{Comment.count} comments"
