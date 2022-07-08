SUITS = ['H', 'S', 'D', 'C']
VALUES = [2, 3, 4, 5, 6, 7, 8, 9, 10, 'J', 'Q', 'K', 'A']
SCORES = { Player: 0, Dealer: 0 }
WINNING_VALUE = 21
DECISION_VALUE = 17

def prompt(string)
  puts "---> #{string}"
end

def initialized_deck
  SUITS.product(VALUES).shuffle
end

def new_card(game_deck)
  game_deck.pop
end

def show_player_cards(cards_array, total)
  new_array = []
  cards_array.each_with_index do |num, index|
    if index == 0
      new_array << num.to_s
    elsif index + 1 != cards_array.size
      new_array << ", #{num}"
    else
      new_array << " and #{num}"
    end
  end
  new_array.join('') + " for a total of #{total}"
end

def if_ace(values, total)
  (values.count('A')).times do
    total -= 10 if total > WINNING_VALUE
  end
  total
end

def get_total(cards)
  total = 0
  values = cards.map { |card| card[1] }
  values.each do |value|
    if value.to_s.to_i == value
      total += value
    elsif value != 'A'
      total += 10
    else
      total += 11
    end
  end
  if values.include?('A')
    total = if_ace(values, total)
  end
  total
end

def update_total(cards, total)
  values = cards.map { |card| card[1] }
  new_value = values.last
  if new_value.to_s.to_i == new_value
    total += new_value
  elsif new_value != 'A'
    total += 10
  else
    total += 11
  end
  total = get_total(cards) if values.include?('A')
  total
end

def bust?(total)
  total > WINNING_VALUE
end

def find_winner(dealer_total, player_total)
  if dealer_total == player_total
    "Tie"
  elsif dealer_total < player_total
    'Player'
  else
    "Dealer"
  end
end

def winning_message(winner, dealer_cards, player_cards, dealer_total,
                    player_total)
  puts "-" * 25
  puts "Dealer has: " + show_player_cards(dealer_cards, dealer_total)
  puts "Player has: " + show_player_cards(player_cards, player_total)
  if winner == 'Tie'
    prompt "It's a tie."
  elsif winner == 'Player'
    prompt "You win!"
  else
    prompt "You lose. The Dealer wins."
  end
  puts "-" * 25
end

def display_scores
  prompt "The score is Player:   #{SCORES[:Player]}"
  prompt "             Computer: #{SCORES[:Dealer]}"
end

def add_to_score(winner)
  if winner == 'Player'
    SCORES[:Player] += 1
  elsif winner == 'Dealer'
    SCORES[:Dealer] += 1
  end
  display_scores
end

def play_again?
  prompt "Do you want to play again?(y or n)"
  answer = gets.chomp.downcase
  answer.start_with?('y')
end

def reset_scores
  SCORES.transform_values! { |v| v = 0 }
end

loop do # main loop
  dealer_cards = []
  player_cards = []

  game_deck = initialized_deck

  2.times do
    dealer_cards << new_card(game_deck)
    player_cards << new_card(game_deck)
  end

  dealer_total = get_total(dealer_cards)
  player_total = get_total(player_cards)

  prompt "Dealer has: #{dealer_cards[0]} and unknown card"

  loop do
    hit_or_stay = nil
    prompt "You have: #{show_player_cards(player_cards, player_total)}"

    loop do
      prompt "Do you want to hit(h) or stay(s)?"
      hit_or_stay = gets.chomp
      break if hit_or_stay == 's' || hit_or_stay == 'h'
      prompt "Sorry it must be h or s."
    end

    if hit_or_stay == 'h'
      prompt "You choose to hit!"
      player_cards << new_card(game_deck)
      player_total = update_total(player_cards, player_total)
    end
    break if player_total > WINNING_VALUE || hit_or_stay == 's'
  end

  if bust?(player_total)
    prompt "You Busted"
    winner = "Dealer"
    winning_message(winner, dealer_cards, player_cards, dealer_total,
                    player_total)
    add_to_score(winner)
    next unless SCORES[:Player] >= 5 || SCORES[:Dealer] >= 5
    reset_scores
    play_again? ? next : break
  end

  prompt "Dealers turn...."

  loop do
    prompt "Dealer has: #{show_player_cards(dealer_cards, dealer_total)}"
    break if dealer_total >= DECISION_VALUE
    prompt 'Dealer Hits!'
    dealer_cards << new_card(game_deck)
    dealer_total = update_total(dealer_cards, dealer_total)
  end

  if bust?(dealer_total)
    prompt "Dealer busted!"
    winner = "Player"
    winning_message(winner, dealer_cards, player_cards, dealer_total,
                    player_total)
    add_to_score(winner)
    next unless SCORES[:Player] >= 5 || SCORES[:Dealer] >= 5
    reset_scores
    play_again? ? next : break
  end

  winner = find_winner(dealer_total, player_total)
  winning_message(winner, dealer_cards, player_cards, dealer_total,
                  player_total)
  add_to_score(winner)
  next unless SCORES[:Player] >= 5 || SCORES[:Dealer] >= 5
  reset_scores
  break unless play_again?
end
prompt 'Thank you for playing'