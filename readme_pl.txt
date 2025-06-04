# baza danych w skryptcie bash

Struktura:
  - database.sh - Główny skrypt wykonywalny
  - folder "tables" - Tutaj zdefiniowane są wszystkie tabele (aktualnie tylko jedna). Każda tabela jest zdefiniowana za pomocą dwóch plików "{table_name}.txt" i "{table_name}_data.txt".
     "{table_name}.txt" przechowuje wszystkie rekordy tabeli
     "{table_name}_data.txt" przechowuje strukturę tabeli. Tutaj definiowany jest id_index, aby upewnić się, że id są unikalne, oraz wszystkie reguły walidacji przypisywane są do pól
  - folder "validation_rules" - Tutaj zdefiniowane są wszystkie reguły walidacji. Każda reguła walidacji przyjmuje 4 argumenty:
    - table_name - nazwa tabeli
    - argument - niektóre reguły wymagają dodatkowego argumentu, np. min:3 sprawdza, czy wartość ma co najmniej 3 znaki. Liczba minimalnych znaków jest przekazywana jako $argument
    - column - kolumna, która jest sprawdzana
    - value - wartość, która musi przejść walidację

  Każda reguła wypisuje zmienną error. Jeśli walidacja przeszła pomyślnie, wartość error to "None", w przeciwnym razie wartość error zawiera opis błędu.

  Przykład walidacji:
   ./validation_rules/min.sh "users" "3" "name" "jj" -> "Field 'name' must have at least 3 characters."
   ./validation_rules/min.sh "users" "3" "name" "Jacob" -> "None"

   Przykład reguły walidacji zdefiniowanej w "{table_name}_data.txt":
   validate::pesel:unique,digits:11

Po otwarciu użytkownikowi przedstawiane jest 5 opcji:
 - exit
 - create
 - read
 - delete
 - sh
Użytkownik może wybrać dowolną z opcji, wpisując jej nazwę lub skrót. Wybór akcji uruchamia odpowiadającą funkcję.

exit
  Kończy działanie programu z kodem 0.

create
  Rozpoczyna proces "insert". Najpierw użytkownik jest proszony o wprowadzenie wszystkich pól. Następnie wyświetlane są wartości pól i użytkownik jest proszony o potwierdzenie utworzenia. Jeśli odmówi, zostaje cofnięty do wprowadzania wartości pól.
  Jeśli zaakceptuje, rozpoczyna się walidacja. Plik "{table_name}_data.txt" jest czytany linia po linii i sprawdzane czy zaczynają się od "validate::". Kiedy taka linia zostanie znaleziona, jest cięta na potrzebne dane do uruchomienia reguły walidacji.
  Przykład:
  validate::phone_number:digits:9,unique
  jest cięty na
  phone_number digits:9,unique
  phone_number jest przypisywane do $field, a reszta jest cięta na rule_names i rule_arguments za pomocą ",". W pętli for każa reguła jest uruchamiana. Tutaj uruchamiane są:
  ./validation_rules/unique.sh "users" "" "phone_number" "{{wartość zmiennej phone_number}}"
  ./validation_rules/digits.sh "users" "9" "phone_number" "{{wartość zmiennej phone_number}}"

  Wynik reguły jest zapisywany do $error i jeśli $error nie jest równy "None", walidacja zatrzymuje dalsze sprawdzanie. Jest to 1. dla optymalizacji i 2. aby nie nadpisywać błędu.
  W naszym przykładzie, jeśli phone_number nie byłby unikalny, ale miałby 9 cyfr, bez break reguła digits nadpisałaby $error na "None" i walidacja przeszłaby pomimo, że wartość phone_number nie byłaby unikalna.

  Po walidacji, jeśli $error to "None", id_index jest odczytywany i inkrementowany w "{table_name}_data.txt". Następnie nowy rekord jest wstawiany do "{table_name}.txt".

read
  Użytkownik jest proszony o wprowadzenie pola, według którego chce przeszukać tabelę, oraz wartości, której ma być równa.
  Następnie $search_by jest sprawdzane, czy jest poprawnym polem. Jeśli tak, "{table_name}.txt" jest przeszukiwane w poszukiwaniu linii zawierającej ciąg "|${search_by}:${search_value}|".
  Jeśli linia zostanie znaleziona, jest wyświetlana. Jeśli nie, wyświetlany jest komunikat "Nie znaleziono rekordu z $search_by:$search_value". Jeśli $search_value to pusty ciąg znaków, cały plik "{table_name}.txt" jest odczytywany za pomocą cat.

delete
  Użytkownik jest proszony o wprowadzenie id rekordu, który chce usunąć. Jeśli rekord zostanie znaleziony, jest wyświetlany, a użytkownik jest proszony o potwierdzenie usunięcia.
