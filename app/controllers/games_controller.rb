require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @start_time = Time.now
    @display_letters = generate_grid(9)
    @letters = @display_letters.join
  end

  def score
    @end_time = Time.now
    @result = run_game(params[:my_text],
                       params[:letters], # params letters
                       params[:starttime],
                       @end_time) # Time.now
  end

  private

  def generate_grid(numbers_letters)
    Array.new(numbers_letters) { ('A'..'Z').to_a.sample }
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def run_game(attempt, grid, start_time, end_time)
    arraygrid = grid.chars
    start_time = Time.new(start_time)
    delta_time = end_time - start_time
    score_and_message(attempt, arraygrid, delta_time)
  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def score_and_message(attempt, grid, time)
    if included?(attempt.upcase, grid)
      if english_word?(attempt)
        score = compute_score(attempt, time)
        { score: score, message: 'well done' }
      else
        { score: 0, message: 'not an english word' }
      end
    else
      { score: 0, message: 'not in the grid' }
    end
  end

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    JSON.parse(response.read)['found']
  end
end
