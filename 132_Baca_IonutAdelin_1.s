.data
    memorie: .space 1048576
    O: .long 0
    co: .long 0
    formatc_dig: .asciz "%d"
    N: .long 0
    i: .long 0
    j: .long 0
    des: .long 0
    dim: .long 0
    formata_lsc: .asciz "%d: ((%d, %d), (%d, %d))\n"
    li: .long 0
    lf: .long 0
    ci: .long 0
    cf: .long 0
    lgsec: .long 0
    k: .long 0
    formata_poz: .asciz "((%d, %d), (%d, %d))\n"
    format_str: .asciz "%s"
    directory: .space 256
    dir: .space 4
    fds: .space 4
    fd: .space 4
    mesaj_eroare_dir: .asciz "Failed to open directory"
    entry: .space 4
    dir1: .asciz "."
    dir2: .asciz ".."
    vt: .space 4
    format_concatenare: .asciz "%s/%s"
    file: .space 256
    mesaj_eroare_file: .asciz "Failed to open file"
    file_ds: .space 1024
    stat: .space 144
    status: .space 144
    mesaj_eroare_fstat: .asciz "Failed to get file stats"
    sizeul: .long 0
    comprehension: .long 0
    formata_concrete: .asciz "%d\n%d\n"

.text

f_add:
    #ret
    #%esp
    #-4(%esp)
    pushl %ebp
    movl %esp, %ebp
    
    pushl $N #citesc nr de adaugari
    pushl $formatc_dig
    call scanf
    addl $8, %esp

    cmpl $0, N #daca nr de adaugari este 0 sar la sf
    je sf_f_add

    movl $0, k #contorizator pentru adaugari
    et_parcurgere_adaugari:
        pushl $des #citesc descriptorul
        pushl $formatc_dig
        call scanf
        addl $8, %esp

        pushl $dim #citesc dimensiunea
        pushl $formatc_dig
        call scanf
        addl $8, %esp

        #transform dimensiunea in blocuri
        movl $0, %edx
        movl dim, %eax
        movl $8, %ecx
        divl %ecx
        movl %eax, dim
        cmpl $0, %edx
        je et_rest0
        addl $1, dim
        et_rest0:

        #pun 0-uri in coordonate in cazul in care nu e spatiu in memorie
        movl $0, ci
        movl $0, cf
        movl $0, li
        movl $0, lf

        movl $0, i #contorizator linii
        et_parc_linii_add:
            movl $0, lgsec

            movl $0, j #contorizator coloane
            et_parc_coloane_add:
                #calculez pozitia din memorie in %eax ca fiind 1024xi+j
                movl i, %eax
                movl $0, %edx
                movl $1024, %ecx
                mull %ecx
                addl j, %eax

                movl des, %ecx
                cmpb %cl, (%edi, %eax, 1)
                je et_afisare_add
                
                #daca e 0 adaug 1 la sec, altfel revine la 0
                cmpb $0, (%edi, %eax, 1)
                je et_eSpatiu
                movl $0, lgsec
                jmp et_compara
                et_eSpatiu:
                addl $1, lgsec

                et_compara:
                movl lgsec, %ecx #compar lgsec sa vad daca e cat dim
                cmpl %ecx, dim
                jne et_nuAmGasitSec #daca nu, mai caut

                #daca da, retin liniile si coloana de final si pun descriptorul pe pozitii
                movl i, %edx
                movl %edx, lf
                movl %edx, li
                movl j, %edx
                movl %edx, cf

                et_pun_des: #pun descriptorul pe lgsec pozitii de la dr spre st
                    movl des, %ebx
                    movb %bl, (%edi, %eax, 1)

                    subl $1, lgsec
                    subl $1, %eax #lgsec e nr de pozitii, iar %eax pozitia in memorie

                    cmpl $0, lgsec
                    jne et_pun_des #daca n am ajuns pe 0 repet

                    #altfel retin coloana de inceput si fac afisarea
                    addl $1, %eax
                    movl $0, %edx
                    movl $1024, %ecx
                    divl %ecx 
                    movl %edx, ci #restul impartirii lui %eax+1 la 1024 este coloana de inceput

                    jmp et_afisare_add

                et_nuAmGasitSec:
                addl $1, j
                cmpl $1024, j #daca ajunge la sfarsit trece de repetare
            jne et_parc_coloane_add

            addl $1, i #daca ajunge la sfarsit trece de repetare
            cmpl $1024, i
        jne et_parc_linii_add

    et_afisare_add:
    #printf(formata_lsc, des, li, ci, lf, cf)
    pushl cf
    pushl lf
    pushl ci
    pushl li
    pushl des
    pushl $formata_lsc
    call printf
    addl $24, %esp
    et_dupaaf:
    
    addl $1, k
    movl k, %ecx
    cmpl N, %ecx
    jne et_parcurgere_adaugari  #daca ajunge la N trece de repetare

    sf_f_add:
    popl %ebp
    ret

f_get:
    pushl %ebp
    movl %esp, %ebp

    pushl $des #citesc descriptorul
    pushl $formatc_dig
    call scanf
    addl $8, %esp
    movl des, %ebx

    #pun 0-uri in coordonate in cazul in care nu e spatiu in memorie
    movl $0, ci
    movl $0, cf
    movl $0, li
    movl $0, lf

    movl $0, i
    et_parc_linii_get:

        movl $0, j
        et_parc_coloane_get:
            #calculez pozitia din memorie in %eax ca fiind 1024xi+j
            movl i, %eax
            movl $0, %edx
            movl $1024, %ecx
            mull %ecx
            addl j, %eax

            cmpb %bl, (%edi, %eax, 1) #daca gasesc descriptorul cautat, sar la et respectiva si ii caut finalul
            je et_get_gasit

            addl $1, j
            cmpl $1024, j
            jne et_parc_coloane_get

        addl $1, i
        cmpl $1024, i
        jne et_parc_linii_get

    jmp et_afisare_get

    et_get_gasit:
        movl i, %ecx
        movl %ecx, li
        movl j, %ecx
        movl %ecx, ci

        subl $1, i #folosesc eticheta cauta final si pentru parcurgerea de linii, asa ca scad una inainte(nu stiu daca un fisier poate fi pe o singura linie) 
        et_cauta_final:
            addl $1, i

            et_parcurgere_coloane_get:
                #calculez pozitia din memorie in %eax ca fiind 1024xi+j
                movl i, %eax
                movl $0, %edx
                movl $1024, %ecx
                mull %ecx
                addl j, %eax

                cmpb %bl, (%edi, %eax, 1)
                jne et_afisare_get

                movl i, %ecx
                movl %ecx, lf
                movl j, %ecx
                movl %ecx, cf 

                addl $1, j
                cmpl $1024, j
                jne et_parcurgere_coloane_get

            movl $0, j
            cmpl $1023,i
            jne et_cauta_final

    et_afisare_get:
        pushl cf
        pushl lf
        pushl ci
        pushl li
        pushl $formata_poz
        call printf
        addl $20, %esp

    popl %ebp
    ret

f_delete:
    pushl %ebp
    movl %esp, %ebp

    pushl $des #citesc descriptorul
    pushl $formatc_dig
    call scanf
    addl $8, %esp
    movl des, %ebx

    #pun 0-uri in coordonate in cazul in care nu e spatiu in memorie
    movl $0, ci
    movl $0, cf
    movl $0, li
    movl $0, lf
    movl $0, k

    movl $0, i
    et_parc_linii_delete:

        movl $0, j
        et_parc_coloane_delete:
            #calculez pozitia din memorie in %eax ca fiind 1024xi+j
            movl i, %eax
            movl $0, %edx
            movl $1024, %ecx
            mull %ecx
            addl j, %eax

            cmpb %bl, (%edi, %eax, 1) #daca gasesc descriptorul cautat, sar la et respectiva si ii caut finalul
            je et_delete_gasit

            addl $1, j
            cmpl $1024, j
            jne et_parc_coloane_delete

        addl $1, i
        cmpl $1024, i
        jne et_parc_linii_delete

    jmp et_sterge_delete

    et_delete_gasit:
        movl $1, k
        movl i, %ecx
        movl %ecx, li
        movl j, %ecx
        movl %ecx, ci

        subl $1, i #folosesc eticheta cauta final si pentru parcurgerea de linii, asa ca scad una inainte(nu stiu daca un fisier poate fi pe o singura linie) 
        et_cauta_final_delete:
            addl $1, i

            et_parcurgere_coloane_delete:
                #calculez pozitia din memorie in %eax ca fiind 1024xi+j
                movl i, %eax
                movl $0, %edx
                movl $1024, %ecx
                mull %ecx
                addl j, %eax

                cmpb %bl, (%edi, %eax, 1)
                jne et_sterge_delete

                movl i, %ecx
                movl %ecx, lf
                movl j, %ecx
                movl %ecx, cf 

                addl $1, j
                cmpl $1024, j
                jne et_parcurgere_coloane_delete

            movl $0, j
            cmpl $1023,i
            jne et_cauta_final_delete

    et_sterge_delete:
        cmpl $0, k #daca nu s-a gasit eticheta sare peste stergere, in cazul ((0,0),(0,0))
        je et_afisare_delete

        movl li, %ecx
        movl %ecx, i
        movl ci, %ecx
        movl %ecx, j

        et_sterge_delete_linie:

            et_sterge_delete_coloana:
                #calculez pozitia din memorie in %eax ca fiind 1024xi+j
                movl i, %eax
                movl $0, %edx
                movl $1024, %ecx
                mull %ecx
                addl j, %eax

                #pun 0 pe pozitia %eax
                movb $0, (%edi, %eax, 1) 

                addl $1, j

                movl i, %ecx
                cmpl %ecx, lf
                jne et_nuUltimaLinie #daca e ultima linie, merg lana la cf

                movl cf, %ecx
                cmpl %ecx, j #j cf
                jg et_afisare_delete

                et_nuUltimaLinie: #daca nu e ultima linie, merg pana la 1023, inclusiv
                    cmpl $1024, j
                    jne et_sterge_delete_coloana

            movl $0, j
            addl $1, i
            movl lf, %ecx
            cmpl %ecx, i #i lf
            jbe et_sterge_delete_linie

    et_afisare_delete: 

    #retin descriptorul si pozitiile de inceput ale elementului anterior diferit de 0
    movl $0, li
    et_cautaPrimaLinie:
        movl $0, ci
        et_cautaPrimaColoana:
            #calculez pozitia din memorie in %eax ca fiind 1024xi+j
            movl li, %eax
            movl $0, %edx
            movl $1024, %ecx
            mull %ecx
            addl ci, %eax

            movl $0, %ebx
            movb (%edi, %eax, 1), %bl

            cmpb $0, (%edi, %eax, 1)
            jne et_inceput_afisare_delete

            addl $1, ci
            cmpl $1024, ci
            jne et_cautaPrimaColoana

        addl $1, li
        cmpl $1024, li
        jne et_cautaPrimaLinie

    jmp et_sfarsit_delete

    et_inceput_afisare_delete:
    movl $0, %ecx
    movl $0, %ebx
    movb (%edi, %ecx, 1), %bl

    movl $0, i
    et_parcurgereLinii_delete:

        movl $0, j
        et_parcurgereColoane_delete:
            #calculez pozitia din memorie in %eax ca fiind 1024xi+j
            movl i, %eax
            movl $0, %edx
            movl $1024, %ecx
            mull %ecx
            addl j, %eax

            cmpb %bl, (%edi, %eax, 1) #daca e acelasi descriptor, sare peste afisare
            je et_acelasiDescriptor
            
            #daca e descriptor 0
            subl $1, %eax
            cmpb $0, (%edi, %eax, 1)
            je et_posibil0_delete
            addl $1, %eax

            #printf(formata_lsc, des, li, ci, lf, cf)

            cmpl $0, j #daca e pe prima coloana, tb sa treaca pe ultima coloana de pe linia anterioara
            jne et_jNuE0_delete

            cmpl $0, i
            je et_jNuE0_delete #scot si cazul particular de pe prima linie
            
            subl $1, i
            movl $1024, j

            et_jNuE0_delete:
                subl $1, j #altfel trec pe coloana anterioara

            pushl j #afisez
            pushl i
            pushl ci
            pushl li
            pushl %ebx
            pushl $formata_lsc
            call printf
            addl $24, %esp

            addl $1, j #revin la linia si coloana de dinainte de afisare
            movl $0, %edx
            movl j, %eax
            movl $1024, %ecx
            divl %ecx
            addl %eax, i
            movl %edx, j

            et_posibil0_delete:
            #calculez pozitia din memorie in %eax ca fiind 1024xi+j
            movl i, %eax
            movl $0, %edx
            movl $1024, %ecx
            mull %ecx
            addl j, %eax

            #retin inceputul si descriptorul
            movl i, %ecx
            movl %ecx, li
            movl j, %ecx
            movl %ecx, ci
            movb (%edi, %eax, 1), %bl

            et_acelasiDescriptor:
            addl $1, j
            cmpl $1024, j
            jne et_parcurgereColoane_delete

        addl $1, i
        cmpl $1024, i
        jne et_parcurgereLinii_delete

    movl $1048575, %ecx
    cmpb $0, (%edi, %ecx, 1)
    je et_sfarsit_delete

    #daca ultimul element e diferit de 0, ii fac afisarea
    pushl $1023
    pushl $1023
    pushl ci
    pushl li
    pushl %ebx
    pushl $formata_lsc
    call printf
    addl $24, %esp

    et_sfarsit_delete:
    popl %ebp
    ret

f_defragmentation:
    pushl %ebp
    movl %esp, %ebp

    movl $0, %ebx
    movb (%edi), %bl #descriptor
    movl $-1, dim #dimensiunea unei secvente a unui descriptor(-1 pt ca o sa mai treca odata prin poz 0)

    movl $0, i
    movl $0, j
    et_parc_linii_defragmentation:
        
        et_parc_coloane_defragmentation:
            #calculez pozitia din memorie in %eax ca fiind 1024xi+j
            movl i, %eax
            movl $0, %edx
            movl $1024, %ecx
            mull %ecx
            addl j, %eax

            addl $1, dim #daca nu e 0, adaug la lungimea secventei 1(si daca dim e initializata cu 0, dim va fi egala cu lg sec)

            cmpb %bl, (%edi, %eax, 1) #daca e acelasi descriptor ii caut capatul
            je et_mai_departe_defragmentation

            #aici am dat de alt descriptor si ii cautam o posibila pozitionare mai buna a secventei noastre pana in pozitia %eax, pe care o mut in k
            movl %eax, k

            movl %eax, %ecx
            subl $1, %ecx

            cmpb $0, (%edi, %ecx, 1)
            je et_urm_descriptor

            movl i, %ecx #pornesc cautarea de la (li, ci)=(i,j-1), unde (i, j) e descriptor diferit
            movl %ecx, li

            movl j, %ecx
            movl %ecx, ci
            subl $1, ci

            cmpl $-1, ci #verific cazul in care (i, j) e la inceput de linie si tb sa sar pe linia de sus
            jne et_cauta_linie

            movl $1023, ci #cazul de pe prima coloana

            cmpl $0, li
            je et_cauta_linie #daca e pe prima linie trece peste

            subl $1, li

            et_cauta_linie:
                movl $0, lgsec #eu adun indiferent de ce dau pana la ultimul descriptor diferit de 0/descriptorul al carui spatiu il caut, deci scad 1 de acum pentru contorizarea descriptorului diferit de cele 2 opt

                et_cauta_coloana:
                    #calculez pozitia din memorie in %eax ca fiind 1024xli+ci
                    movl li, %eax
                    movl $0, %edx
                    movl $1024, %ecx
                    mull %ecx
                    addl ci, %eax

                    addl $1, lgsec

                    #daca e liber pe pozitia asta (0 sau chiar descriptorul nostru), o contorizez + un descriptor diferit de cele 2 opt
                    cmpb $0, (%edi, %eax, 1)
                    je et_mai_cauta_spatii

                    cmpb %bl, (%edi, %eax, 1)
                    je et_mai_cauta_spatii

                    #(li, ci) elementul diferit    

                    movl ci, %ecx
                    movl %ecx, cf
                    addl $1, cf

                    movl li, %ecx
                    movl %ecx, lf

                    addl dim, %eax #pozitia ultimului elem din sirul nou
     
                    movl %eax, %ecx

                    movl li, %eax
                    addl $1, %eax
                    movl $0, %edx
                    movl $1024, %esi
                    mull %esi

                    cmpl %ecx, %eax #(li+1)*1024>%ecx
                    jg et_aceeasiLinie #daca secventa trece de limita 1023, sare pe urmatoarea linie(nu are cum sa depaseasca pozitia initiala)

                    addl $1, lf
                    movl $0, cf

                    et_aceeasiLinie:

                    movl i, %ecx
                    movl %ecx, li

                    movl j, %ecx
                    subl dim, %ecx #(j(pozitia elementului de dupa sir=capat drept+1)-dimensiune=poz init)
                    movl %ecx, ci

                    cmpl $0, ci #ci<0
                    jge et_interschimba_defragmentation

                    movl $1024, %ecx
                    subl dim, %ecx
                    movl %ecx, ci
                    subl $1, li

                    jmp et_interschimba_defragmentation
                  
                    et_mai_cauta_spatii:
                    subl $1, ci
                    cmpl $-1, ci
                    jne et_cauta_coloana

                cmpl $0, li
                je et_pregatiri_interschimbare

                movl $1023, ci

                subl $1, li
                cmpl $-1, li
                jne et_cauta_linie

            et_pregatiri_interschimbare:

            movl $0, cf
            movl $0, lf

            movl i, %ecx
            movl %ecx, li

            movl j, %ecx
            subl dim, %ecx
            movl %ecx, ci

            cmpl $0, ci #ci<0
            jge et_interschimba_defragmentation

            movl $0, ci

            et_interschimba_defragmentation:

                movl li, %eax
                movl $0, %edx
                movl $1024, %ecx
                mull %ecx
                addl ci, %eax

                movb $0, (%edi, %eax, 1) #li/ci inceputul secventei

                movl lf, %eax
                movl $0, %edx
                movl $1024, %ecx
                mull %ecx
                addl cf, %eax

                movb %bl, (%edi, %eax, 1) #lf/cf urmatorul inceput al secventei

                addl $1, cf
                addl $1, ci

                subl $1, dim
                cmpl $0, dim
                jne et_interschimba_defragmentation

            et_urm_descriptor:
            movl k, %eax
            movb (%edi, %eax, 1), %bl
            movl $0, dim

            et_mai_departe_defragmentation:
            addl $1, j
            cmpl $1024, j

            jne et_parc_coloane_defragmentation

        movl $0, j

        addl $1, i
        cmpl $1024, i
        jne et_parc_linii_defragmentation

    et_afisare_defragmentation:

    #retin descriptorul si pozitiile de inceput ale elementului anterior diferit de 0
    movl $0, li
    et_cautaPrimaLinied:
        movl $0, ci
        et_cautaPrimaColoanad:
            #calculez pozitia din memorie in %eax ca fiind 1024xi+j
            movl li, %eax
            movl $0, %edx
            movl $1024, %ecx
            mull %ecx
            addl ci, %eax

            movl $0, %ebx
            movb (%edi, %eax, 1), %bl

            cmpb $0, (%edi, %eax, 1)
            jne et_inceput_afisare_defragmentation

            addl $1, ci
            cmpl $1024, ci
            jne et_cautaPrimaColoanad

        addl $1, li
        cmpl $1024, li
        jne et_cautaPrimaLinied

    jmp et_sfarsit_defragmentation

    et_inceput_afisare_defragmentation:
    movl $0, %ecx
    movl $0, %ebx
    movb (%edi, %ecx, 1), %bl

    movl $0, i
    et_parcurgereLinii_defragmentation:

        movl $0, j
        et_parcurgereColoane_defragmentation:
            #calculez pozitia din memorie in %eax ca fiind 1024xi+j
            movl i, %eax
            movl $0, %edx
            movl $1024, %ecx
            mull %ecx
            addl j, %eax

            cmpb %bl, (%edi, %eax, 1) #daca e acelasi descriptor, sare peste afisare
            je et_acelasiDescriptord
            
            #daca e descriptor 0
            subl $1, %eax
            cmpb $0, (%edi, %eax, 1)
            je et_posibil0_defragmentation
            addl $1, %eax

            #printf(formata_lsc, des, li, ci, lf, cf)

            cmpl $0, j #daca e pe prima coloana, tb sa treaca pe ultima coloana de pe linia anterioara
            jne et_jNuE0_defragmentation

            cmpl $0, i
            je et_jNuE0_defragmentation #scot si cazul particular de pe prima linie
            
            subl $1, i
            movl $1024, j

            et_jNuE0_defragmentation:
                subl $1, j #altfel trec pe coloana anterioara

            pushl j #afisez
            pushl i
            pushl ci
            pushl li
            pushl %ebx
            pushl $formata_lsc
            call printf
            addl $24, %esp

            addl $1, j #revin la linia si coloana de dinainte de afisare
            movl $0, %edx
            movl j, %eax
            movl $1024, %ecx
            divl %ecx
            addl %eax, i
            movl %edx, j

            et_posibil0_defragmentation:
            #calculez pozitia din memorie in %eax ca fiind 1024xi+j
            movl i, %eax
            movl $0, %edx
            movl $1024, %ecx
            mull %ecx
            addl j, %eax

            #retin inceputul si descriptorul
            movl i, %ecx
            movl %ecx, li
            movl j, %ecx
            movl %ecx, ci
            movb (%edi, %eax, 1), %bl

            et_acelasiDescriptord:
            addl $1, j
            cmpl $1024, j
            jne et_parcurgereColoane_defragmentation

        addl $1, i
        cmpl $1024, i
        jne et_parcurgereLinii_defragmentation

    movl $1048575, %ecx
    cmpb $0, (%edi, %ecx, 1)
    je et_sfarsit_defragmentation

    #daca ultimul element e diferit de 0, ii fac afisarea
    pushl $1023
    pushl $1023
    pushl ci
    pushl li
    pushl %ebx
    pushl $formata_lsc
    call printf
    addl $24, %esp

    et_sfarsit_defragmentation:
    popl %ebp
    ret

f_comprehension:
    pushl %ebp
    movl %esp, %ebp

    #scanf("%s", directory); citesc path-ul spre folder
    pushl $directory
    pushl $format_str
    call scanf
    addl $8, %esp

    #dir = opendir(directory);
    pushl $directory
    call opendir
    addl $4, %esp
    movl %eax, dir

    cmpl $0, dir
    je et_eroare_dir

    pushl dir
    call readdir
    addl $4, %esp
    movl %eax, entry

    et_parcurgere_fisiere:
        movl entry, %ecx #verific ca fisierul sa nu fie .
        addl $11, %ecx
        pushl %ecx
        pushl $dir1
        call strcmp
        addl $8, %esp

        cmpl $0, %eax
        je et_citire_fisierNou

        movl entry, %ecx #verific ca fisierul sa nu fie ..
        addl $11, %ecx
        pushl %ecx
        pushl $dir2
        call strcmp
        addl $8, %esp

        cmpl $0, %eax
        je et_citire_fisierNou

        movl entry, %ecx
        addl $11, %ecx

        pushl %ecx #creez path-ul spre fisier
        pushl $directory
        pushl $format_concatenare
        pushl $512
        pushl $file
        call snprintf
        addl $20, %esp

        movl $5, %eax #deschid fisierul
        movl $file, %ebx
        movl $0, %ecx
        movl $0, %edx
        int $0x80
        movl %eax, fds #descriptorul de la citire in fds

        cmpl $-1, %eax #cazul in care e o eroare la citirea fisierului
        je et_eroare_file

        movl $0, %edx
        movl $255, %ecx
        divl %ecx
        addl $1, %edx
        movl %edx, des #creez file descriptorul pe care o sa-l pun in matrice
        
        #pushl $stat
        #pushl fds
        #call fstat
        #addl $8, %esp #creez structura de status a fisierului pe care vreau sa-l adaug

        movl $108, %eax
        movl fds, %ebx
        movl $stat, %ecx
        int $0x80

        cmpl $-1, %eax
        je et_eroare_fstat

        leal stat, %ecx
        addl $20, %ecx
        movl (%ecx), %eax

        movl $0, %edx
        movl $1024, %ecx
        divl %ecx

        cmpl $0, %edx
        je et_restul0

            addl $1, %eax

        et_restul0:

        movl %eax, sizeul #size retine dimensiunea in kb

        movl $0, %edx
        movl $8, %ecx
        divl %ecx

        cmpl $0, %edx
        je et_are_rest0

        addl $1, %eax

        et_are_rest0:

        movl %eax, dim

        #pun 0-uri in coordonate in cazul in care nu e spatiu in memorie
        movl $0, ci
        movl $0, cf
        movl $0, li
        movl $0, lf

        movl $0, i #contorizator linii
        et_parc_linii_concrete:
            movl $0, lgsec

            movl $0, j #contorizator coloane
            et_parc_coloane_concrete:
                #calculez pozitia din memorie in %eax ca fiind 1024xi+j
                movl i, %eax
                movl $0, %edx
                movl $1024, %ecx
                mull %ecx
                addl j, %eax

                movl des, %ecx
                cmpb %cl, (%edi, %eax, 1)
                je et_afisare_concrete
                
                cmpb $0, (%edi, %eax, 1)
                je et_eSpatiu_concrete
                movl $0, lgsec
                jmp et_compara_concrete
                et_eSpatiu_concrete:
                addl $1, lgsec

                et_compara_concrete:
                movl lgsec, %ecx #compar lgsec sa vad daca e cat dim
                cmpl %ecx, dim
                jne et_nuAmGasitSec_concrete #daca nu, mai caut

                #daca da, retin liniile si coloana de final si pun descriptorul pe pozitii
                movl i, %edx
                movl %edx, lf
                movl %edx, li
                movl j, %edx
                movl %edx, cf

                et_pun_des_concrete: #pun descriptorul pe lgsec pozitii de la dr spre st
                    movl des, %ebx
                    movb %bl, (%edi, %eax, 1)

                    subl $1, lgsec
                    subl $1, %eax #lgsec e nr de pozitii, iar %eax pozitia in memorie

                    cmpl $0, lgsec
                    jne et_pun_des_concrete #daca n am ajuns pe 0 repet

                    #altfel retin coloana de inceput si fac afisarea
                    addl $1, %eax
                    movl $0, %edx
                    movl $1024, %ecx
                    divl %ecx 
                    movl %edx, ci #restul impartirii lui %eax+1 la 1024 este coloana de inceput

                    jmp et_afisare_concrete

                et_nuAmGasitSec_concrete:
                addl $1, j
                cmpl $1024, j #daca ajunge la sfarsit trece de repetare
            jne et_parc_coloane_concrete

            addl $1, i #daca ajunge la sfarsit trece de repetare
            cmpl $1024, i
        jne et_parc_linii_concrete

        et_afisare_concrete:
        #inainte de afisare pun id-urile fisierelor in memorie sa le inchid
        movl $1, comprehension #am pus cel putin 1 id
        movl $0, %ecx
        et_cauta_spDesc:
            cmpl $0, (%esi, %ecx, 4)
            jne et_nu_pune

            movl fds, %ebx
            movl %ebx, (%esi, %ecx, 4)

            et_nu_pune:
            incl %ecx
            cmpl $256, %ecx
            je et_inainte_de_afisare
            cmpl $0, (%esi, %ecx, 4)
            jne et_cauta_spDesc

        et_inainte_de_afisare:
        #printf(formata_concrete, des, sizeul)
        pushl sizeul
        pushl des
        pushl $formata_concrete
        call printf
        addl $12, %esp

        #printf(formata_lsc, des, li, ci, lf, cf)
        pushl cf
        pushl lf
        pushl ci
        pushl li
        pushl des
        pushl $formata_lsc
        call printf
        addl $24, %esp
        et_dupaaf_concrete:

        jmp et_citire_fisierNou 
        
        et_eroare_fstat: #cazul in care e o eroare la citirea fisierului sau la statusul acestuia
            pushl $mesaj_eroare_fstat
            call printf
            addl $4, %esp

            pushl fds
            call close
            addl $4, %esp

            jmp et_citire_fisierNou

        et_eroare_file: #cazul in care e o eroare la citirea fisierului sau la statusul acestuia
            pushl $mesaj_eroare_file
            call printf
            addl $4, %esp

        et_citire_fisierNou: #mai citesc un fisier
        pushl dir
        call readdir
        addl $4, %esp
        movl %eax, entry

        cmpl $0, %eax #daca n am terminat ce era in document, continui sa citesc
        jne et_parcurgere_fisiere

    jmp et_inchide_director
    et_eroare_dir:
        pushl $mesaj_eroare_dir
        call printf
        addl $4, %esp

    et_inchide_director:
        pushl dir
        call closedir
        addl $4, %esp

    et_sfarsit_comprehension:
    popl %ebp
    ret

.global main

main:#scanf("%d", &O)
    pushl $O
    pushl $formatc_dig
    call scanf
    addl $8, %esp

    leal memorie, %edi
    leal file_ds, %esi

movl $0, %ecx
et_parc_op:
    #for(int i=0;i<O;i++)
    #scanf("%d", &co)
    #aleg fct potriv
    cmpl O, %ecx
    je et_exit
    addl $1, %ecx

    pushl %ecx
    pushl $co
    pushl $formatc_dig
    call scanf
    addl $8, %esp
    popl %ecx

    cmpl $1, co
    je et_add
    cmpl $2, co
    je et_get
    cmpl $3, co
    je et_delete
    cmpl $4, co
    je et_defragmentation
    cmpl $5, co
    je et_comprehension

et_add:
    pushl %ecx #pun pe stiva %ecx-ul ca sa nu l pierd la apelarea fct f_add

    call f_add

    popl %ecx #scot %ecx-ul dupa fct

    jmp et_parc_op

et_get:
    pushl %ecx #pun pe stiva %ecx-ul ca sa nu l pierd la apelarea fct f_add

    call f_get

    popl %ecx #scot %ecx-ul dupa fct

    jmp et_parc_op

et_delete:
    pushl %ecx #pun pe stiva %ecx-ul ca sa nu l pierd la apelarea fct f_add

    call f_delete

    popl %ecx #scot %ecx-ul dupa fct

    jmp et_parc_op

et_defragmentation:
    pushl %ecx #pun pe stiva %ecx-ul ca sa nu l pierd la apelarea fct f_add

    call f_defragmentation

    popl %ecx #scot %ecx-ul dupa fct

    jmp et_parc_op

et_comprehension:
    pushl %ecx #pun pe stiva %ecx-ul ca sa nu l pierd la apelarea fct f_add

    call f_comprehension

    popl %ecx #scot %ecx-ul dupa fct

    jmp et_parc_op

et_exit:
    cmpl $0, comprehension #daca nu am trecut prin concrete, nu are ce inchide
    je et_sf

    movl $0, %ecx
        et_inchide:
            cmpl $0, (%esi, %ecx, 4)
            je et_nu_sterge

            movl $6, %eax
            movl (%esi, %ecx, 4), %ebx
            int $0x80

            et_nu_sterge:
            incl %ecx
            cmpl $256, %ecx
            je et_sf
            cmpl $0, (%esi, %ecx, 4)
            jne et_inchide

    et_sf:
    pushl $0
    call fflush
    popl %eax
    movl $1, %eax
    movl $0, %ebx
    int $0x80