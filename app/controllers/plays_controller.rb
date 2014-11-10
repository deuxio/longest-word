require 'open-uri'
require 'json'

class PlaysController < ApplicationController

  def game
    if params[:grid_size]
      grid_size = params[:grid_size].to_i
      @grid = generate_grid(grid_size)
    end

  end

  def score
    @result = {}
    @grid = params[:grid]
    if params[:attempt]
      end_time = Time.now.to_i
      @attempt = params[:attempt]
      @result = run_game(@attempt, @grid.split(","), session[:start_time], end_time )
    end
  end

  private

  def generate_grid(grid_size)
    alphabet = ('a'..'z').to_a
    grid = []
    grid_size.times { grid << alphabet.sample.upcase }
    session[:start_time] = Time.now.to_i
    grid
  end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of @result
    @result[:time] = end_time - start_time
    if @attempt.downcase.split(//).all? { |letter| grid.map(&:downcase).include? letter }
      open("http://api.wordreference.com/0.8/80143/json/fren/#{attempt.downcase}") do |stream|
        translations = JSON.parse(stream.read)
        if translations['Error']
          @result[:message] = "not an english word !"
          @result[:score] = 0
        else
          @result[:translation] = translations['term0']['PrincipalTranslations']['0']['FirstTranslation']['term']
          @result[:score] = @attempt.length**4 - @result[:time]**2
          @result[:message] = "well done !"
        end
      end
    else
      @result[:score] = 0
      @result[:message] = "not in the grid !"
    end
    @result
  end

end
