-- Function to create a book structure
local function createBook(title, id)
    return { title = title, id = id }
end

-- Function to divide the array into two parts
local function partition(arr, low, high, key)
    local pivot = arr[high][key]
    local i = low - 1

    for j = low, high - 1 do
        if arr[j][key] <= pivot then
            i = i + 1
            arr[i], arr[j] = arr[j], arr[i]
        end
    end

    arr[i + 1], arr[high] = arr[high], arr[i + 1]
    return i + 1
end

-- Quick Sort function
local function quickSort(arr, low, high, key)
    if low < high then
        local pivot = partition(arr, low, high, key)
        quickSort(arr, low, pivot - 1, key)
        quickSort(arr, pivot + 1, high, key)
    end
end

-- Function to print book list
local function printBooks(bookList)
    for _, book in ipairs(bookList) do
        print(book.title, book.id)
    end
end

-- Sample book data
local sampleBooks = {
    createBook("Book3", 789),
    createBook("Book4", 234),
    createBook("Book1", 123),
    createBook("Book2", 456)
}

-- Ask the user if they want to enter their own data or use sample data
print("Do you want to enter your own data for books? (yes/no)")
local choice = io.read()

local books = {}
if choice == "yes" then
    repeat
        print("Enter book title:")
        local title = io.read()

        print("Enter book id:")
        local id = tonumber(io.read())

        table.insert(books, createBook(title, id))
        print("Do you want to add another book? (yes/no)")
    until io.read() ~= "yes"
else
    books = sampleBooks
end

-- Print the list of books before sorting
print("\nList of books before sorting:")
printBooks(books)

-- Ask the user for the field by which to sort the list
print("\nEnter the field name to sort the list (e.g., 'id', 'title'):")
local fieldToSort = io.read()

-- Sort the list of books based on the user-provided field
quickSort(books, 1, #books, fieldToSort)

-- Print the sorted list of books
print("\nList of books after sorting by " .. fieldToSort .. ":")
printBooks(books)
