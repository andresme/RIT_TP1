Indexing, Searching and Display
=======

The first homework of the Information Retrieval course at *[ITCR](http://www.tec.ac.cr/Paginas/Tecnol%C3%B3gico%20de%20Costa%20Rica.aspx)*.
This homework will be develop using only perl programming language.  

Indexing
=======

The indexing tool will create three files which will contain the following.

Frequency File
--------------
* Relative path to the document in the collection.
* Number of diferent terms in the file.
* Max frequency.
* List of pairs (term, repetitions).

Weight File
-----------
* Relative path to the document in the collection.
* Number of diferent terms in the file.
* Norm of vector (sqrt(sum(weights^2))).
* List of pairs (term, weight)

Vocabulary File
---------------
* Term.
* Number of documents in which the term is.

Each line of the frequency and the weight file are one document of the collection.

To invoke this tool you need to call it from terminal as follows:

	./generar file_with_stopwords path_to_subfolders 'pattern of files to analyze' prefix_for_files_to_create

