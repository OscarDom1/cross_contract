#[derive(Copy, Debug, Serde, Drop)]
struct Book {
    id: u16,
    title: felt252,
    author: felt252,
    year: u16,
    edition: felt252,
}

#[starknet::interface]
pub trait ISchoolLibrary<TContractState> {
    fn add_book(ref self: TContractState, book: Book);
    fn borrow_book(ref self: TContractState, book: Book) -> bool;
}

#[starknet::contract]
mod SchoolLibrary {
    use starknet::event::EventEmitter;
    use core::starknet::storage::{
        Map, StoragePointerReadAccess, StoragePointerWriteAccess, StoragePathEntry,
    };
    use super::Book;

    #[storage]
    struct Storage {
        book_record: Map<(u16, felt252, felt252, u16, felt252), bool> // Map<Book, bool> // entry <-> write
    }

    #[event]
    #[derive(Copy, Drop, starknet::Event)]
    enum Event {
        AddBook: AddBook,
    }

    #[derive(Copy, Drop, starknet::Event)]
    struct AddBook {
        book_name: Book,
        response: felt252,
    }

    #[abi(embed_v0)]
    impl SchoolLibraryImpl of super::ISchoolLibrary<ContractState> {
        fn add_book(ref self: ContractState, book: Book) {
            let book_key = (book.id, book.title, book.author, book.year, book.edition);
            let exists = self.book_record.entry(book_key).read();

            if exists {
                self.emit(AddBook { book_name: book, response: 'Book already exists' });
            }

            // Additional validations
            if book.title == 0_felt252 || book.author == 0_felt252 {
                self
                    .emit(
                        AddBook { book_name: book, response: 'Invalid book title or author' },
                    );
            }

            self.book_record.entry(book_key).write(true);

            self.emit(AddBook { book_name: book, response: 'Book has been added' });
        }


        fn borrow_book(ref self: ContractState, book: Book) -> bool {
            let book_exists = self
                .book_record
                .entry((book.id, book.title, book.author, book.year, book.edition))
                .read();

            if book_exists {
                return true;
            } else {
                return false;
            }
        }
    }
}


// 2. StudentRecord
// - Borrow Books from SchoolLibrary
use core::starknet::ContractAddress;

#[starknet::interface]
pub trait IStudentRecord<TContractState> {
    fn borrow_book_from_lib(
        ref self: TContractState, book: Book, student_name: felt252, lib_address: ContractAddress,
    ) -> bool;
}

#[starknet::contract]
mod StudentRecord {
    use starknet::storage::StorageMapWriteAccess;
    use super::ISchoolLibraryDispatcherTrait;
    use starknet::storage::{Map};
    use super::ISchoolLibraryDispatcher;
    use core::starknet::ContractAddress;
    use super::Book;

    #[storage]
    struct Storage {
        borrow_books: Map<(u16, felt252, felt252, u16, felt252), felt252> // student_name => book_name
    }

    impl StudentRecordImpl of super::IStudentRecord<ContractState> {
        fn borrow_book_from_lib(
            ref self: ContractState,
            book: Book,
            student_name: felt252,
            lib_address: ContractAddress,
        ) -> bool {
            let lib_dispatcher = ISchoolLibraryDispatcher { contract_address: lib_address };

            let check = lib_dispatcher.borrow_book(book);

            if check {
                self
                    .borrow_books
                    .write(
                        (book.id, book.title, book.author, book.year, book.edition), student_name,
                    );
                return true;
            } else {
                return false;
            }
        }
    }
}
