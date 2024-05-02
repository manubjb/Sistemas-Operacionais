#!/bin/bash

#Funcao para checar se o dialog ta instalado 0 
dialogInstalado() {
   if ! dialog -v dialog &>/dev/null;then
      dialog --infobox "Dialog está instalado!" 0 0
      sleep 3
      return 1
         
   else
      dialog --infobox "Erro: dialog não está instalado para usar esta função" 0 0
         sleep 3
   fi
}


#Funcao para ver processos em execucao 1
processosExecucao() {
   clear
   PROCESSOS=$(ps -e -o pid,user,cmd,pcpu,pmem,size,priority --sort=-%cpu | head -n 20 | sed '1d')
   dialog --msgbox "$PROCESSOS" 0 0
}


#Funcao para encerrar os processos pelo nome 2 
encerrarProcessoNome() {
    nome=$(dialog --stdout --inputbox "Insira o nome do processo que deseja encerrar:" 0 0)
        killall -9 "$nome"
        dialog --msgbox "Processo com nome $nome encerrado com sucesso." 0 0
}

#Funcao para encerrar os processos pelo PID 3 
encerrarProcessoPID() {
    pid=$(dialog --stdout --inputbox "Insira o PID do processo que deseja encerrar:" 0 0)
    
    # Verifica se o PID corresponde a um processo em execução
    if ps -p "$pid" &>/dev/null; then
        kill -9 "$pid"
        dialog --msgbox "Processo com PID $pid encerrado com sucesso." 0 0
    else
        dialog --msgbox "Erro: PID $pid não corresponde a um processo em execução." 0 0
    fi
}

#Funcao adicionar um usuario ao sistema 4
criarUsuario() {
    clear
    usuario=$(dialog --stdout --inputbox "Insira o nome do usuário a ser cadastrado:" 0 0)
    useradd "$usuario" 2> /dev/null
    if [ $? -eq 0 ]; then
        dialog --infobox "Usuário cadastrado com sucesso. Lembre-se de adicionar o usuário a um grupo." 0 0
        sleep 3
    else
        dialog --msgbox "Falha ao cadastrar usuário." 0 0
    fi
}

#Funcao adicionar senha ao usuario 5
addSenha() {
    clear
    usuario=$(dialog --stdout --inputbox "Informe o nome do usuário para cadastrar a senha:" 0 0)
    senha=$(dialog --stdout --insecure --passwordbox "Informe a senha:" 0 0)
    echo "$usuario:$senha" | chpasswd 2> /dev/null
    if [ $? -eq 0 ]; then
        dialog --infobox "Senha adicionada com sucesso." 0 0
        sleep 3
    else
        dialog --msgbox "Erro ao adicionar senha." 0 0
    fi
}


#Funcao cadastrar grupo 6
criarGrupo(){
   clear
   grupo=$(dialog --stdout --inputbox "Insira o nome do grupo a ser cadastrado" 0 0) 
   groupadd $grupo 2> /dev/null
         if [ $? -eq 0 ];then
         dialog --infobox "Grupo cadastrado com sucesso" 0 0
      sleep 3
         else
         dialog --msgbox "Falha ao cadastrar grupo" 0 0
         fi
}

#Funcao adicionar usuario a um grupo 7
addUserGrupo() {
   clear
   usuario=$(dialog --stdout --inputbox "Informe o nome do usuário" 0 0) 
   grupo=$(dialog --stdout --inputbox "Informe o nome do grupo" 0 0) 
   gpasswd -a "$usuario" "$grupo" 2> /dev/null
      if [ $? -eq 0 ];then
         dialog --infobox " Usuário $usuario cadastrado no grupo $grupo com sucesso" 0 0
         sleep 3
      else
         dialog --msgbox " Erro ao cadastrar $usuario ao grupo $grupo" 0 0
      fi
}

#Funcao criar usuario e adicionar a um grupo ja existente 8
criareAdicionar() {
   clear
   usuario=$(dialog --stdout --inputbox "Insira o nome do usuário a ser cadastrado" 0 0)
   useradd $usuario 2> /dev/null
   if [ $? -eq 0 ]; then
      dialog --infobox "Usuário cadastrado com sucesso." 0 0
      sleep 3
   else
      dialog --msgbox "Falha ao cadastrar usuário" 0 0
   fi
   grupo=$(dialog --stdout --inputbox "Informe o nome do grupo" 0 0) 
   gpasswd -a $usuario $grupo 2> /dev/null
   if [ $? -eq 0 ]; then
      dialog --infobox "Usuário $usuario cadastrado no grupo $grupo com sucesso." 0 0
      sleep 3
   else
      dialog --msgbox "Erro ao cadastrar $usuario ao grupo $grupo." 0 0
   fi
}


#Funcao deletar usuario do grupo 9
deletarUsuario(){
   clear
   RES    clear
   RESPOSTA=$(dialog --stdout --inputbox "Tem certeza que deseja deletar um usuario [s/n]: " 0 0) 
   test "$RESPOSTA" = "n" && exit
   usuario=$(dialog --stdout --inputbox "Informe o nome do usuário a ser deletado: " 0 0)

   # Verifica se o grupo existe antes de tentar deletar
   if grep -q "^$usuario:" /etc/group; then
      userdel "$usuario" 2> /dev/null
      if [ $? -eq 0 ]; then
         dialog --infobox "Usuário $usuario deletado com sucesso" 0 0
         sleep 3
      else
         dialog --msgbox "ERRO ao deletar usuario $usuario" 0 0
      fi
   else
      dialog --msgbox "Usuário $usuario não encontrado" 0 0
   fi
}


#Funcao deletar grupo 10
deletarGrupo() {
   clear
   RESPOSTA=$(dialog --stdout --inputbox "Tem certeza que deseja deletar um grupo [s/n]: " 0 0) 
   test "$RESPOSTA" = "n" && exit
   grupo=$(dialog --stdout --inputbox "Informe o nome do grupo a ser deletado: " 0 0)

   # Verifica se o grupo existe antes de tentar deletar
   if grep -q "^$grupo:" /etc/group; then
      groupdel "$grupo" 2> /dev/null
      if [ $? -eq 0 ]; then
         dialog --infobox "Grupo $grupo deletado com sucesso" 0 0
         sleep 3
      else
         dialog --msgbox "ERRO ao deletar grupo $grupo" 0 0
      fi
   else
      dialog --msgbox "Grupo $grupo não encontrado" 0 0
   fi
}

#Funcao Configurar data de ultima modificacao de senha do usuario 11 consertar
configurarDataUltimaModSenha() {
   # Solicita o nome do usuário usando uma input box
    nome_usuario=$(dialog --inputbox "Digite o nome do usuário:" 8 40 --stdout)

    # Solicita uma nova data usando um calendário
    nova_data=$(dialog --stdout --calendar "Selecione uma data" 0 0)

    # Verifica se a data foi selecionada
    if [ "$?" == "0" ]; then
        echo "Data de modificação da senha para o usuário $nome_usuario definida para $nova_data."
    else
        echo "Data não selecionada"
    fi
}




#Funcao Configurar num minimo de dias para modificacao de senha 12
configurarNumMinDiasModSenha() {
    clear
    dialog --title "Configurar número mínimo de dias para modificar senha" --msgbox "Esta opção define o número mínimo de dias que um usuário deve esperar antes de poder modificar sua senha." 0 0

    minimoDias=$(dialog --stdout --inputbox "Digite o número mínimo de dias:" 0 0)

    # Configura o número mínimo de dias para modificar a senha
    chage -m "$minimoDias" $(dialog --stdout --inputbox "Digite o nome do usuário:" 0 0)

    dialog --msgbox "Número mínimo de dias para modificar senha configurado com sucesso." 0 0
}

#Funcao Configurar num maximo de dias para modificacao de senha 13
configurarNumMaxDiasModSenha(){
    clear
    dialog --title "Configurar número maximo de dias para modificar senha" --msgbox "Esta opção define o número maximo de dias que um usuário deve esperar antes de poder modificar sua senha." 0 0

    maxDias=$(dialog --stdout --inputbox "Digite o número maximo de dias:" 0 0)

    # Configura o número mínimo de dias para modificar a senha
    chage -M "$maxDias" $(dialog --stdout --inputbox "Digite o nome do usuário:" 0 0)

    dialog --msgbox "Número maximo de dias para modificar senha configurado com sucesso." 0 0
}


#Funcao Configurar dias de aviso de um usuario 14
configurarNumDiasAviso(){
    clear
    dialog --title "Configurar número de dias de aviso" --msgbox "Esta opção define o número de dias de aviso de um usuario" 0 0

    diasAviso=$(dialog --stdout --inputbox "Digite o número de dias de aviso:" 0 0)

    # Configura o número mínimo de dias para modificar a senha
    chage -W "$diasAviso" $(dialog --stdout --inputbox "Digite o nome do usuário:" 0 0)

    dialog --msgbox "Número de dias de aviso do usuario configurado com sucesso." 0 0
}


#Funcao  Mostrar as configurações de senha de um usuário 15
mostrarConfigSenha(){
   usuario=$(dialog --stdout --inputbox "Informe o nome do usuário que deseja ver configuracoes: " 0 0) 
   dialog --msgbox "$(chage -l $usuario)" 0 0
}

#Funcao  Mostrar de quais grupos um usuário faz parte 16
mostrarGruposUsuario(){
   usuario=$(dialog --stdout --inputbox "Informe o nome do usuário: " 0 0)
   grupos=$(groups $usuario)
   dialog --msgbox "O usuário $usuario faz parte dos grupos: $grupos" 0 0

}


#Funcao para que um usuário se torne administrador 17
tornarAdmin() {
   local usuario="$1"
   usuario=$(dialog --stdout --inputbox "Informe o nome do usuário que deseja tornar administrador" 0 0) 
   if id "$usuario" &>/dev/null; then
      dialog --msgbox "Adicionando usuário $usuario ao grupo sudo..." 0 0
      sudo usermod -aG sudo "$usuario"
      if [ $? -eq 0 ]; then
         dialog --msgbox "Usuário $usuario tornou-se administrador com sucesso." 0 0
         return 0
      else
         dialog --msgbox "Erro ao adicionar $usuario ao grupo sudo." 0 0
         return 1
      fi
   else
      dialog --msgbox "Erro: O usuário $usuario não existe." 0 0
      return 1
   fi
}


#Exibir usuarios que usaram o sistema recentemente 18
usuariosRecentemente(){
   usuariosRecente=$(last -n 5)
   dialog --msgbox "Usuários que usaram o sistema recentemente: $usuariosRecente " 0 0
}

#Funcao listar usuarios 19
listarUsuarios(){
   clear
   list=`cat /etc/passwd| cut -d: -f1 | sort -u` 
   echo -e "{FONTE}33[${list}\e[m" 
   total=`cat /etc/passwd| wc -l`
   echo "Total de usuários cadastrados: $total" 
   sleep 5
}

#Funcao listar Grupos 20
listargrupos(){
   clear
   list=`cat /etc/group| cut -d: -f1 | sort -u`
   echo "$list"
   total=`cat /etc/group| wc -l`
   echo "Total de grupos cadastrados: $total"
   sleep 5
}

ajuda() {
    dialog --title "Ajuda" --msgbox "Emanuelly Borges, Adson e Higor. Disciplina: Sistemas Operacionais" 10 70
}
sair(){
clear
exit
}

while true; do
    ESCOLHA=$(dialog --help-button --help-label "Ajuda" --stdout --menu 'Escolha Sua Opção' \
           0 0 0 33  'Verificar se dialog esta instalado' \
                 1 'Ver os processos em execução' \
                 2 'Encerrar um processo (nome)' \
                 3 'Encerrar processo (PID)' \
                 4 'Adicionar um usuário ao sistema' \
                 5 'Configurar senha' \
                 6 'Adicionar um grupo ao sistema' \
                 7 'Adicionar um usuario já existente a um grupo já existente' \
                 8 'Criar usuario e adicionar a grupo já existente' \
                 9 'Apagar usuário' \
                 10 'Apagar grupo' \
                 11 'Configurar data de última modificação de senha do usuário' \
                 12 'Configurar o número mínimo de dias p/ modificação da senha do usuário' \
                 13 'Configurar o número máximo de dias p/ modificação da senha do usuário' \
                 14 'Configurar numero de dias de aviso de um usuário' \
                 15 'Mostrar as configuracoes de senha de um usuário' \
                 16 'Mostrar de quais grupos um dado usuario faz parte' \
                 17 'Permitir que o usuário se torne admin' \
                 18 'Exibe os usuários que utilizaram o sistema recentemente' \
                 19 'Listar usuários' \
                 20 'Listar grupos' \
                 21 'Sair')

if [ $? == 2 ] 
then 
	dialog --title "Ajuda" --msgbox "Emanuelly Borges, Adson e Higor. Disciplina: Sistemas Operacionais" 10 70
else 


   case "$ESCOLHA" in
        33) dialogInstalado ;;
        1) processosExecucao;;
        2) encerrarProcessoNome;;
        3) encerrarProcessoPID;;
        4) criarUsuario;;
        5) addSenha;;
        6) criarGrupo ;;
        7) addUserGrupo ;;
        8) criareAdicionar ;;
        9) deletarUsuario ;;
        10) deletarGrupo ;;
        11) configurarDataUltimaModSenha ;;
        12) configurarNumMinDiasModSenha ;;
        13) configurarNumMaxDiasModSenha ;;
        14) configurarNumDiasAviso ;;
        15) mostrarConfigSenha ;;
        16) mostrarGruposUsuario ;;
        17) tornarAdmin ;;
        18) usuariosRecentemente ;;
        19) listarUsuarios ;;
        20) listargrupos ;;
        21) sair ;;
   esac
   fi
done