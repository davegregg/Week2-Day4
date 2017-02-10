#!/usr/bin/env ruby
require_relative 'deck'
require 'tty'
require 'pry'

class Game
  attr_accessor   :player_hand, :dealer_hand,
                  :winner, :debug, :deck
  def initialize
    self.winner          = nil
    self.player_hand     = []
    self.dealer_hand     = []
    self.deck            = []
    self.debug           = false
  end

  def hand
    hand = []
    hand << deck.draw
    hand << deck.draw
    hand
  end

  def player_plays
    prompt = TTY::Prompt.new
    show("Player",true,player_hand)
    until prompt.select("Hit or Stay?", %w(Hit Stay)) == "Stay"
      player_hand << deck.draw
      show("Player",true,player_hand)
      if score(player_hand) >= 21 then break end
    end
  end

  def dealer_plays
    show("Dealer",false,dealer_hand)
    until score(dealer_hand) >= 16
      dealer_hand << deck.draw
      show("Dealer",false,dealer_hand)
      if score(dealer_hand) >= 21 then break end
    end
  end

  def show_both_scores
    d = score(dealer_hand)
    p = score(player_hand)
    puts ("Player:#{p} Dealer:#{d}")
  end

  def blackjack(score)
    score == 21
  end

  def bust(score)
    score > 21
  end

  def beat(my_score,their_score)
    (my_score > their_score) && !bust(their_score) && !bust(my_score)
  end

  def six(hand)
    (hand.length >= 6) && (score(hand) < 21)
  end

  def player_wins
    pl = score(player_hand)
    d  = score(dealer_hand)
    six(player_hand) ||
    (!bust(pl) &&
    (blackjack(pl) || bust(d) || beat(pl,d)))
  end

  def dealer_wins
    pl = score(player_hand)
    d  = score(dealer_hand)
    !bust(d) &&
    (blackjack(d) || bust(pl) || beat(d,pl))
  end

  def declare_winner
    if player_wins
      puts "Player Wins"
    elsif dealer_wins
      puts "Dealer Wins"
    else
      if player_hand.length > dealer_hand.length
        puts "Player Wins by more cards"
      elsif dealer_hand.length > player_hand.length
        puts "Dealer Wins by more cards"
      else
        puts "Player Wins by Tie"
      end
    end
    show_both_scores
  end

  def prepare_deck
    self.deck = Deck.new
    self.deck.shuffle
  end

  def prepare_hands
    self.dealer_hand = hand
    self.player_hand = hand
  end

  def main_sequence
    show("Dealer",false,dealer_hand)
    unless dealer_wins
      player_plays
      dealer_plays if score(player_hand) < 21 && score(dealer_hand) < 16
    end
    show("Dealer",true,dealer_hand)
    show("Player",true,player_hand)
    declare_winner
  end

  def rematch
    prompt = TTY::Prompt.new
    s = "Would you like a rematch (y/n)?"
    if prompt.ask(s)=='y'
      Game.new.play
    else
      puts "Thanks for playing"
    end
  end

  def play
    prepare_deck
    prepare_hands
    main_sequence
    rematch
  end

  def show(who,show_first,hand)
    card_number = 1
    puts "#{who}"
    hand.each{|card|
      if show_first || card_number > 1 || debug
        puts "   #{card.value} of #{card.suit}"
      end
      card_number += 1
    }
    puts "   Score:#{score(hand)}" if debug
  end

  def score(hand)
    hand.reduce(0){|sum,card| sum += card.value}
  end
end

Game.new.play
