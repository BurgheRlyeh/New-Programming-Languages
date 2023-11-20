-module(text_stat).
-export([start/0]).

% Function to read text from console
read_text_from_console() ->
    io:format("Enter the text: "),
    Text = io:get_line(""),
    lists:reverse(lists:dropwhile(fun(C) -> C == $\n end, lists:reverse(Text))).

% Function to read text from a file
read_text_from_file(FileName) ->
    {ok, File} = file:open(FileName, [read]),
    Lines = try get_all_lines(File)
        after file:close(File)
        end,
    Text = lists:flatten(Lines),
    Text.

% Function to get all lines from the file
get_all_lines(File) ->
    case io:get_line(File, "") of
        eof  -> [];
        Line -> [Line | get_all_lines(File)]
    end.

% Function to count word frequency in the text
word_frequency(Text) ->
    Words = string:tokens(string:to_lower(Text), " .,!?-\"\n\t"),
    WordFreq = lists:foldl(
        fun(W, Acc) ->
            case lists:keyfind(W, 1, Acc) of
                false ->
                    [{W, 1} | Acc];
                {W, Freq} ->
                    NewFreq = Freq + 1,
                    lists:keyreplace(W, 1, Acc, {W, NewFreq})
            end
        end,
        [],
        Words
    ),
    SortedFreq = lists:sort(fun({_, Freq1}, {_, Freq2}) -> Freq1 > Freq2 end, WordFreq),
    SortedFreq.

% Function to get top N words from word frequency list
top_n_words(_, 0) ->
    [];
top_n_words([], _) ->
    [];
top_n_words([{Word, _} | T], N) ->
    [Word | top_n_words(T, N - 1)].

% Function to output statistics to console
output_to_console(WordCount, TopWords) ->
    io:format("Number of words: ~p~n", [WordCount]),
    io:format("Top 10 most common words: ~p~n", [TopWords]).

% Function to output statistics to a file
output_to_file(WordCount, TopWords, FileName) ->
    {ok, File} = file:open(FileName, [write]),
    io:format(File, "Number of words: ~p~n", [WordCount]),
    io:format(File, "Top 10 most common words: ~p~n", [TopWords]),
    file:close(File).

% Main function to start the program
start() ->
    io:format("Welcome! How do you want to enter the text?~n"),
    io:format("1. Enter directly from the console~n"),
    io:format("2. Pass the file name containing the text~n"),
    Choice = case io:get_line("Choice: ") of
        "1\n" -> read_text_from_console();
        "2\n" -> {ok, [FileName]} = io:fread("Enter the file name: ", "~s"),
            Text = read_text_from_file(FileName),
            Text
        end,
    {WordCount, TopWords} = {length(string:tokens(string:to_lower(Choice), " .,!?-\"\n\t")), top_n_words(word_frequency(Choice), 10)},
    io:format("Where do you want to output the statistics?~n"),
    io:format("1. Console~n"),
    io:format("2. File~n"),
    case io:get_line("Choice: ") of
        "1\n" -> output_to_console(WordCount, TopWords);
        "2\n" -> io:format("Enter the file name to save statistics: "),
                 % {ok, OutputFileName} = io:get_line(""),
                 % output_to_file(WordCount, TopWords, string:strip(OutputFileName, right))
                 OutputFileName = string:strip(io:get_line(""), right, $\n),
                 output_to_file(WordCount, TopWords, OutputFileName)
    end.
