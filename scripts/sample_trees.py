import math

import sys


def sample_trees(input_file, output_file, num_trees_to_select=4000):

    # Leggi il file di input

    with open(input_file, 'r') as infile:

        lines = infile.readlines()


    # Identifica dove iniziano gli alberi (di solito dopo la lista delle specie e i metadati)

    tree_start_index = 0

    for i, line in enumerate(lines):

        if line.startswith("tree "):  # Gli alberi iniziano comunemente con 'tree '

            tree_start_index = i

            break


    # L'header include tutte le righe prima del primo albero

    header = lines[:tree_start_index]

    last_line = lines[-1]  # Tipicamente c'è una riga finale dopo il blocco degli alberi


    # I dati degli alberi reali iniziano da tree_start_index

    trees = lines[tree_start_index:-1]

    total_trees = len(trees)


    # Calcola l'intervallo per il campionamento regolare

    interval = math.floor(total_trees / num_trees_to_select)


    # Seleziona gli alberi a intervalli regolari

    selected_trees = [trees[i] for i in range(0, total_trees, interval)][:num_trees_to_select]


    # Scrivi l'header, gli alberi campionati e l'ultima riga nel file di output

    with open(output_file, 'w') as outfile:

        outfile.writelines(header)

        outfile.writelines(selected_trees)

        outfile.write(last_line)


    print(f"File con {num_trees_to_select} alberi campionati creato: {output_file}")


# Verifica se gli argomenti posizionali sono stati forniti

if len(sys.argv) != 3:

    print("Uso: python script.py <file_di_input> <file_di_output>")

else:

    input_file = sys.argv[1]  # Primo argomento: file di input

    output_file = sys.argv[2]  # Secondo argomento: file di output

    sample_trees(input_file, output_file, num_trees_to_select=4000)

