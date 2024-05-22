#!/bin/bash
#사용자별 아이디 
#userDir="jihun"
 userDir="junghun"
# userDir="jk"
# userDir="jichan"
# userDir="dong"


verS="44"
if [[ "$userDir" == "jihun" ]]; then
	mesonTokenId="gepcnntekjtxewpaf149b02394db8f8b"
	gagaTokenId="rcrtuhgfjymciqin7054a067ca595896"
elif [[ "$userDir" == "junghun" ]]; then
	mesonTokenId="tqkqnohucnopdqaqd9ecac5408035d40"
	gagaTokenId="niyqndpwdbatzatpe32b4b2e62cd8fe6"
elif [[ "$userDir" == "jk" ]]; then
	mesonTokenId="xoljoavhxasxblrk1bab5ec4ac9cd04c"
	gagaTokenId="oojebhncqvujyjdj92764c6ffbc7d984"
elif [[ "$userDir" == "jichan" ]]; then
	mesonTokenId="gepcnntekjtxewpaf149b02394db8f8b"
	gagaTokenId="rcrtuhgfjymciqin7054a067ca595896"
elif [[ "$userDir" == "dong" ]]; then
	mesonTokenId="dkrdrpllcnpozgsf45ba829e92a12b21"
	gagaTokenId="elremnoqqdrhceloc48557d63550badf"
fi	
export APP_IP=$(curl https://ipinfo.io/ip)
hostname=$(hostname)

oldstatus="old" 
echo "지훈 샤드리움 노드 프로그램 실행중 20초만 기다리세요..... 세팅중..... "
while true; do  
  echo " 키파일 체크중 ....... "
  source v_$hostname.txt 
  file="v_$(hostname).txt" 
  if [ ! -f "$file" ]; then
    chkfile="N"
    echo -e "\033[31m 키파일이 없습니다. 다운로드하거나 지훈한테 문의하세요! \033[0m"
  else 
    chkfile="Y"
     echo " 키파일 확인 완료! "
  fi
# 노드실행  
  echo " 노드 상태 확인중 ........ " 
  dockerstatus=$(docker inspect -f '{{.State.Status}}' shardeum-dashboard 2>/dev/null)
  
  nodeinfo=$(docker exec -it shardeum-dashboard operator-cli status)
  sleep 15
  
  nodestatus=$(echo "$nodeinfo" | awk '/state:/ {print $NF}')
  lockedStake=$(echo "$nodeinfo" | awk '/lockedStake:/ {print $NF}')
  
  valver=$(echo "$verinfo"  | awk '/runnningValidatorVersion:/ {print $NF}')
  
  lockedStake=$(expr "$lockedStake" : ".*'\([0-9]*\.[0-9]*\)'" | cut -d '.' -f 1)
  lockedStake=${lockedStake:-0} 
  if [[ "$lockedStake" == "''" ]]; then lockedStake=0
  fi
  echo "스테이트상의 스테이킹수량 :$lockedStake"
  
  if [[ "$nodestatus" == *"top"* ]]; then
    echo  -e "\033[31m  노드 스탑 상태 노드 재실행 .......20초기다리세요 \033[0m"
    docker exec -it shardeum-dashboard bash -c "export  APP_IP=$APP_IP  && operator-cli gui start"
    docker exec -it shardeum-dashboard bash -c "export  APP_IP=$APP_IP  && operator-cli start"
    sleep 20
    nodeinfo=$(docker exec -it shardeum-dashboard operator-cli status)
    sleep 15
  
    nodestatus=$(echo "$nodeinfo" | awk '/state:/ {print $NF}')
  else
    echo " 노드 확인완료! "
  fi  
    currentRewards=$(echo "$nodeinfo" | awk '/currentRewards:/ {print $NF}')
    currentRewards=$(expr "$currentRewards" : ".*'\([0-9]*\.[0-9]*\)'" | cut -d '.' -f 1)
    currentRewards=${currentRewards:-0} 
    if [[ "$currentRewards" == "''" ]]; then currentRewards=0
    fi
  
    lastActiveDate=$(echo "$nodeinfo" | awk -F': ' '/lastActive:/{print $NF}'  | tr -d '\r' | xargs)
    if [ -z "$lastActiveDate" ] || [ "$lastActiveDate" == "''" ] || [ "$lastActiveDate" == "null"  ]; then
      lastActiveDate="Nothing Active Date"
    else
     lastActiveDate=$(TZ=Asia/Seoul date -d "$(echo "$lastActiveDate" | cut -d ' ' -f 1-5)" '+%Y-%m-%d %H:%M:%S %Z')
    fi
    verinfo=$(docker exec -it shardeum-dashboard operator-cli version)
    valver=$(echo "$verinfo"  | awk '/runnningValidatorVersion:/ {print $NF}')
    sleep 15
    stakeinfo=$(docker exec -it shardeum-dashboard operator-cli stake_info $my_add )
    sleep 15
    stakeval=$(echo "$stakeinfo"  | awk '/stake:/ {print $NF}')
    stakeval=$(expr "$stakeval" : ".*'\([0-9]*\.[0-9]*\)'" | cut -d '.' -f 1)
    stakeval=${stakeval:-0} 
    if [[ "$stakeval" == "''" ]]; then stakeval=0
    fi
 
    my_nominee_add=$(echo "$stakeinfo"  | awk '/nominee:/ {print $NF}')
    op_nominee_add=$(echo "$nodeinfo"  | awk '/nomineeAddress:/ {print $NF}')
  

  clear
  echo "======================================================================"
  echo "      이 프로그램은 JIHUN 제작하였으며, 배포가 금지됩니다. ver.$verS"
  echo "======================================================================"
  if [  -f "$file" ]; then
    chkfile="Y"
    echo -e "\033[32m - key file : $chkfile \033[0m"
   
  else 
     chkfile="N"
    echo -e "\033[31m - key file : $chkfile \033[0m"
  fi

  if [ "$dockerstatus" == "running" ]; then
    echo -e "\033[32m - 노드 프로그램 설치됨 - 상태: $nodestatus \033[0m"
  else
    echo -e "\033[31m - 노드 프로그램 설치안됨\033[0m"
  fi

  if [[ "$nodestatus" == *"tandby"* ]]; then
    if [[ "$stakeval" == "''" ]]; then stakeval=0
    fi
    if [[ "$stakeval" > 0 ]]; then
      if [[ "$op_nominee_add" != "$my_nominee_add" ]]; then
         echo -e "\033[31m - 노드정보가 다름 -  언스테이킹해야함.\033[0m"
      elif [[ "$op_nominee_add" == "$my_nominee_add" ]]; then
        echo -e "\033[32m - 노드실행중 - 스텐바이 Good !! \033[0m"
      fi
    elif [[ "$stakeval" == 0 ]]; then
      echo -e "\033[31m - 노드실행중 - 스테이킹 안됨\033[0m"
    else  
      echo -e "\033[31m - 노드실행중 - 스테이킹 안됨 \033[0m"
    fi
   
  elif [[ "$nodestatus" == *"yncin"* ]]; then
    echo -e "\033[32m - 노드실행중 - 싱크중 Good !! \033[0m"
  elif [[ "$nodestatus" == *"top"* ]]; then
    echo -e "\033[31m - 노드스탑상태 - 문제발생..\033[0m"
  elif [[ "$nodestatus" == *"yncin"* ]]; then
    echo -e "\033[32m - 노드실행중 - 싱크중 Good !! \033[0m"
  elif [[ "$nodestatus" == *"ctive"* ]]; then
    echo -e "\033[32m - 노드 액티브중..\033[0m"
  else
    echo -e "\033[31m - 샤드리움 서버문제 이거나 노드프로그램이 비정상적입니다. \033[0m"
  fi
 echo " - 스테이킹 수량 : $stakeval"
 echo " - Host name : $hostname "
 echo " - Host Ip : $APP_IP "
 echo " - MY_ADDRESS : $my_add"
 echo -e " - 사용자 : \033[31m $userDir (노드버전:$valver) \033[0m"
echo "======================================================================"
echo ""
echo "3. 수동노드 실행"
echo "4. operator-cli update"
echo "5. 키 파일을 제작"
echo "9. 새로고침"
echo "d. 도커 및 노드 삭제"
echo "h. 호스트명변경"
echo "p. 프록시서버 설치(약5분)"
echo "i. operator-cli status 실행"
echo "g. 가가 노드 설치()"
echo "m. 메손 노드 설치()"
echo "r. RDP 설치"

echo ""
echo "0. 키파일 다운로드"
echo -e "\033[93m1. Node 설치 및 업데이트"
echo -e "\033[93m2. 자동 언스테이킹 및 스테이킹 \033[0m"
echo " (!!!! 필수로 키파일이 존재해야 합니다. )"
echo -e "\033[93me. 나가기\033[0m"
echo "======================================================================"
read -p "명령어 대기중 : " num

case $num in
	0) # get ADDRESS file
	   echo  "키 파일을 다운로드 받습니다."
       wget -O  v_$hostname.txt http://poca.wo.tc/shardeum/$userDir/v_$hostname.txt
       ource v_$hostname.txt 
	   file="v_$(hostname).txt" 
	   if [ ! -f "$file" ]; then
 	    chkfile="N"
 	   else 
 	     chkfile="Y"
 	     echo "지갑주소=$my_add"
         echo "프라이빗키=$PRIV_KEY"
         sleep 5
	   fi
      
       ;;
    
    1) # NODE 삭제 후 설치
       echo "노드를 삭제 후 설치 하거나 업데이트만 할 수 있습니다."
       read -p "노드를 삭제 후 설치 하시겠습니까? (y/n) "  conF
       if [[ "$conf" == "y" ]]; then
         echo "노드 삭제중..."
         rm -rf .shardeum
         docker rm -vf $(docker ps -aq)
         sleep 3
       fi
       echo "노드 설치중..."
 #      docker exec -it shardeum-dashboard bash -c "operator-cli stop"
 #      docker stop shardeum-dashboard
       curl -O https://gitlab.com/shardeum/validator/dashboard/-/raw/main/installer.sh && chmod +x installer.sh && ./installer.sh
       docker ps -a && docker update --restart=always shardeum-dashboard
       echo "1) 노드 설치완료"
       docker exec -it shardeum-dashboard bash -c "export APP_IP=$APP_IP && npm install uuid@latest  && npm install @typescript-eslint/typescript-estree@latest && operator-cli update "
       echo "2) CLI UPDATE 완료"
       sleep 3
       ;; 
    

    2) # 자동 언스테이킹 및 스테이킹 및 노드 상태를 PUSH 텔레그램
while true; do 
  echo "노드 작업상태체크중..."
  if [[ "$my_add" != *"0x"* ]]; then
	echo -e "\033[93m키 파일이 없거나 지갑주소가 정상적이지 않습니다. !!\033[0m"
	read -p "아무키나 누르세요.!! "
	break

  fi
  echo "MY_ADDRESS=$my_add"
  echo "PRIV_KEY=$PRIV_KEY"
  echo "APP_IP=$APP_IP"
  echo "노드 상태 다시 확인중..."
  nodeinfo=$(docker exec -it shardeum-dashboard operator-cli status)
  sleep 15
  
  status=$(echo "$nodeinfo" | awk '/state:/ {print $NF}')
  lastActiveDate=$(echo "$nodeinfo" | awk -F': ' '/lastActive:/{print $NF}'  | tr -d '\r' | xargs)
  if [ -z "$lastActiveDate" ] || [ "$lastActiveDate" == "''" ] || [ "$lastActiveDate" == "null"  ]; then
    lastActiveDate="Nothing Active Date"
  else
   lastActiveDate=$(TZ=Asia/Seoul date -d "$(echo "$lastActiveDate" | cut -d ' ' -f 1-5)" '+%Y-%m-%d %H:%M:%S %Z')
  fi
  currentRewards=$(echo "$nodeinfo" | awk '/currentRewards:/ {print $NF}')
  currentRewards=$(expr "$currentRewards" : ".*'\([0-9]*\.[0-9]*\)'" | cut -d '.' -f 1)
  currentRewards=${currentRewards:-0} 
  if [[ "$currentRewards" == "''" ]]; then currentRewards=0
  fi
    
  echo "노드상태: $status"
  
  verinfo=$(docker exec -it shardeum-dashboard operator-cli version)
  sleep 15
  valver=$(echo "$verinfo"  | awk '/runnningValidatorVersion:/ {print $NF}')
  
  
  stakeinfo=$(docker exec -it shardeum-dashboard operator-cli stake_info $my_add )
  sleep 15
  stakeval=$(echo "$stakeinfo"  | awk '/stake:/ {print $NF}')
  stakeval=$(expr "$stakeval" : ".*'\([0-9]*\.[0-9]*\)'" | cut -d '.' -f 1)
  stakeval=${stakeval:-0} 
  if [[ "$stakeval" == "''" ]]; then stakeval=0
  fi
  
  
  echo "노드 스테이킹 수량 : $stakeval" 
  
  my_nominee_add=$(echo "$stakeinfo"  | awk '/nominee:/ {print $NF}')
  op_nominee_add=$(echo "$nodeinfo"  | awk '/nomineeAddress:/ {print $NF}')
  
 #   echo "Node status searching Coder Msahin & Hercules"
   echo "OP_no_add : $op_nominee_add"
   echo "My_no_add : $my_nominee_add"

  if [[ "$status" == *"tandby"* ]]; then
   
    if [[ "$stakeval" == "''" ]]; then stakeval=0
    fi
    
    if [[ "$stakeval" > 0 ]]; then
      if [[ "$op_nominee_add" != "$my_nominee_add" ]]; then
         echo "노드 언스테이킹 작업중..."
         outText="!! 언스테이킹시도중 "
         
           oldstatus=status
           python3 telego_"$userDir"_2.py "$outText" "$status" "$stakeval||$currentRewards" "$valver" "$lastActiveDate" "$userDir"
           
         
         sleep 15
         docker exec -it shardeum-dashboard  bash -c "export APP_IP=$APP_IP  && echo '$PRIV_KEY' | operator-cli unstake -f"

         sleep 90
#        exit 0
      elif [[ "$op_nominee_add" == "$my_nominee_add" ]]; then
        
        echo "노드정상작동중...  StakeVal: $stakeval"
        outText="노드 정상작동중"
#        if [[ "$status" != "$oldstatus"  ]]; then
         oldstatus=status
          python3 telego_"$userDir"_2.py "$outText" "$status" "$stakeval||$currentRewards" "$valver" "$lastActiveDate" "$userDir"
#        fi
        sleep 3600
#       exit 0
      else  
        echo "노드 스테이킹에러 잠시후 다시 시도합니다."
        outText="노드스테이킹 비정상...다시시도중."
#        if [[ "$status" != "$oldstatus"  ]]; then
          oldstatus=status
          python3 telego_"$userDir"_2.py "$outText" "$status" "$stakeval||$currentRewards" "$valver" "$lastActiveDate" "$userDir"
#        fi
        sleep 3600
      fi
    elif [[ "$stakeval" == 0 ]]; then 
      echo "노드 스테이킹 작업중...: $zaman"
      nodeinfo=$(docker exec -it shardeum-dashboard operator-cli status)
      sleep 15
  
      status=$(echo "$nodeinfo" | awk '/state:/ {print $NF}')
      lastActiveDate=$(echo "$nodeinfo" | awk -F': ' '/lastActive:/{print $NF}'  | tr -d '\r' | xargs)
      if [ -z "$lastActiveDate" ] || [ "$lastActiveDate" == "''" ] || [ "$lastActiveDate" == "null"  ]; then
        lastActiveDate="Nothing Active Date"
      else
       lastActiveDate=$(TZ=Asia/Seoul date -d "$(echo "$lastActiveDate" | cut -d ' ' -f 1-5)" '+%Y-%m-%d %H:%M:%S %Z')
      fi
    
      echo "노드상태: $status"
  
      verinfo=$(docker exec -it shardeum-dashboard operator-cli version)
        sleep 5
      valver=$(echo "$verinfo"  | awk '/runnningValidatorVersion:/ {print $NF}')
  
  
      stakeinfo=$(docker exec -it shardeum-dashboard operator-cli stake_info $my_add )
  
      stakeval=$(echo "$stakeinfo"  | awk '/stake:/ {print $NF}')
      stakeval=$(expr "$stakeval" : ".*'\([0-9]*\.[0-9]*\)'" | cut -d '.' -f 1)
      stakeval=${stakeval:-0} 
      if [[ "$stakeval" == "''" ]]; then stakeval=0
      fi
      echo "노드 스테이킹 수량 : $stakeval" 
  
      my_nominee_add=$(echo "$stakeinfo"  | awk '/nominee:/ {print $NF}')
      op_nominee_add=$(echo "$nodeinfo"  | awk '/nomineeAddress:/ {print $NF}')
      
# 한번 더 체크       
      if [[ "$status" == *"tandby"* ]]; then
       if [[ "$stakeval" == 0 && "$lockedStake" == 0 ]]; then
         if [[ "$op_nominee_add" != "$my_nominee_add" ]]; then
           outText="스테이킹 작업중"
      
           oldstatus=status
           python3 telego_"$userDir"_2.py "$outText" "$status" "$stakeval||$currentRewards" "$valver" "$lastActiveDate" "$userDir"
      
           sleep 15
           docker exec -it shardeum-dashboard bash -c "export APP_IP=$APP_IP  && echo '$PRIV_KEY' | operator-cli stake 10"
    #     exit 0
           sleep 90
         fi
        fi
       fi
    else 
      echo "SHM이 부족하거나, 노드가 비정상,다시 시도중...: $zaman"
      outText="스테이킹불가능 "
      
        oldstatus=status
        python3 telego_"$userDir"_2.py "$outText" "$status" "$stakeval||$currentRewards" "$valver" "$lastActiveDate" "$userDir"
      
      sleep 15
    fi
  elif [[ "$status" == *"yncin"* ]]; then
    
#    if [[ "$stakeval" == "''" ]]; then stakeval=0
#    fi
    echo "노드 싱크중...  StakeVal: $stakeval"
    outText="노드정상작동중"
#   if [[ "$status" != "$oldstatus"  ]]; then
    oldstatus=status
     python3 telego_"$userDir"_2.py "$outText" "$status" "$stakeval||$currentRewards" "$valver" "$lastActiveDate" "$userDir"
#    fi

#   exit 0
    sleep 21600     
   elif [[ "$status" == *"top"* ]]; then 
     echo "노드 멈충...다시시도중..."
     outText="노드STOP - 재실행중"
#     if [[ "$status" != "$oldstatus"  ]]; then
     oldstatus=status
     python3 telego_"$userDir"_2.py "$outText" "$status" "$stakeval||$currentRewards" "$valver" "$lastActiveDate" "$userDir"
#     fi
	 echo  -e "\033[31m  노드 스탑 상태 노드 재실행 .......20초기다리세요 \033[0m"
	 
     docker exec -it shardeum-dashboard bash -c "export  APP_IP=$APP_IP  && operator-cli gui start"
     docker exec -it shardeum-dashboard bash -c "export  APP_IP=$APP_IP  && operator-cli start"
     sleep 120
     
#    exit 0
   elif [[ "$status" == *"ctiv"* ]]; then 
     echo "노드액티브중"
     outText="노드액티브"
#     if [[ "$status" != "$oldstatus"  ]]; then
       oldstatus=status
       python3 telego_"$userDir"_2.py "$outText" "$status" "$stakeval||$currentRewards" "$valver" "$lastActiveDate" "$userDir"
#     fi
     sleep 21600     
#    exit 0
  else
     echo "노드상태 비정상...다시시도중"
     outText="노드상태비정상"
#     if [[ "$status" != "$oldstatus"  ]]; then
       oldstatus=status
       python3 telego_"$userDir"_2.py "$outText" "$status" "$stakeval||$currentRewards" "$valver" "$lastActiveDate" "$userDir"
#     fi
      docker exec -it shardeum-dashboard bash -c "export  APP_IP=$APP_IP  && operator-cli gui start"
      docker exec -it shardeum-dashboard bash -c "export  APP_IP=$APP_IP  && operator-cli start"
      sleep 120
#     exit 0
fi
  
done
;;
    3) # 수동 노드 실행
       echo "수동노드 실행중..."
       docker exec -it shardeum-dashboard bash -c "export  APP_IP=$APP_IP  && operator-cli gui start"
       sleep 7
       docker exec -it shardeum-dashboard bash -c "export  APP_IP=$APP_IP  && operator-cli start"
       sleep 7
       echo "노드 실행 완료 "
       
       ;;
    4) # operator-cli update & npm update
      echo "CLI 업데이트중..."
      docker exec -it shardeum-dashboard bash -c "export APP_IP=$APP_IP && npm install uuid@latest  && npm install @typescript-eslint/typescript-estree@latest && operator-cli update && operator-cli gui start && operator-cli start "
      echo "CLI 업데이트 완료"
      sleep 7
      ;;
    
    5) # 키 파일 제작
       if [ -f "$file" ]; then
         # 파일이 이미 존재할 경우 초기화
         echo "" > "$file"
       else
         # 파일이 존재하지 않을 경우 새로 생성
         touch "$file"
       fi

       read -p "Enter Value for MetaMark Address value: " aa
       read -p "Enter Value for PRiVITE_KEY : " bb

       echo  "my_add=\"$aa\"" >> "$file"
       echo "PRIV_KEY=\"$bb\"" >> "$file"

       echo "Variables Address and Privite Key saved to $file"
       
       ;;
   
    9) # 새로고침
       echo "새로고침 10초!"
       sleep 10
       ;; 
    h) # 새로고침
       echo "호스트명 변경 후 부팅됩니다."
       
       read -p "변경한 호스트명을 입력하세요: " hh
       sudo hostnamectl set-hostname "$hh"&&sudo rm /etc/machine-id &&sudo systemd-machine-id-setup&&sudo reboot
       
       ;; 
       
    p) # 프록시서버설치
    #사용자 별로 프록시 설치 방법이 다르게 세팅
    echo "프록시 서비설치 - 5분정도 소요됩니다..."
    if [[ "$userDir" == "jihun" ]]; then
	wget -O squidsetup1.sh http://poca.wo.tc/shardeum/jihun/squidsetup3.sh && chmod +x squidsetup1.sh && ./squidsetup1.sh
elif [[ "$userDir" == "junghun" ]]; then
	wget -O squidsetup1.sh http://poca.wo.tc/shardeum/junghun/squidsetup3.sh && chmod +x squidsetup1.sh && ./squidsetup1.sh

elif [[ "$userDir" == "jk" ]]; then
	wget -O squidsetup1.sh http://poca.wo.tc/shardeum/jk/squidsetup3.sh && chmod +x squidsetup1.sh && ./squidsetup1.sh

elif [[ "$userDir" == "jichan" ]]; then
	wget -O squidsetup1.sh http://poca.wo.tc/shardeum/jichan/squidsetup3.sh && chmod +x squidsetup1.sh && ./squidsetup1.sh

elif [[ "$userDir" == "dong" ]]; then
	wget -O squidsetup1.sh http://poca.wo.tc/shardeum/dong/squidsetup3.sh && chmod +x squidsetup1.sh && ./squidsetup1.sh

fi

#       wget -O squidsetup1.sh http://poca.wo.tc/shardeum/squidsetup1.sh && chmod +x squidsetup1.sh && ./squidsetup1.sh
       echo "프록시 서비설치완료."
       ;;   
    d) # 새로고침
       echo "도커 및 노드 삭제중 ..."
       rm -rf .shardeum
       docker rm -vf $(docker ps -aq)
       sleep 3
       echo "도커 및 노드 삭제 완료"
       ;; 
    e) # 잘못된 입력
        echo "exit"
        exit 1
        ;;
    i) #operator-cli status
    	 docker exec -it shardeum-dashboard bash -c "operator-cli status"
    	 read -p "아무키나 누르세요.!! "
    ;;
    g) # 부팅시 자동 노드 실행 등록
        curl -o apphub-linux-amd64.tar.gz https://assets.coreservice.io/public/package/60/app-market-gaga-pro/1.0.4/app-market-gaga-pro-1_0_4.tar.gz && tar -zxf apphub-linux-amd64.tar.gz && rm -f apphub-linux-amd64.tar.gz && cd ./apphub-linux-amd64
		sudo ./apphub service remove && sudo ./apphub service install
		sleep 5
		sudo ./apphub service start
		sleep 5
		./apphub status
		sleep 5
		sudo ./apps/gaganode/gaganode config set --token=$gagaTokenId
		sleep 5
		./apphub restart
		sleep 5
       echo "가가 노드 설치 완료"
       sleep 5
       cd ..
        sleep 3

        ;;
    m) # 부팅시 자동 노드 실행 등록
		wget 'https://staticassets.meson.network/public/meson_cdn/v3.1.19/meson_cdn-linux-amd64.tar.gz' && tar -zxf meson_cdn-linux-amd64.tar.gz && rm -f meson_cdn-linux-amd64.tar.gz && cd ./meson_cdn-linux-amd64 && sudo ./service install meson_cdn
		sudo ./meson_cdn config set --token=$mesonTokenId --https_port=443 --cache.size=30
        sudo ./service start meson_cdn
        echo "메손 노드 설치 완료"
        sleep 3
        cd ..
        sleep 3

        ;;    
    r) # RDP 설치
       sudo apt-get install xrdp -y

       sudo systemctl enable --now xrdp

       sudo ufw allow from any to any port 3389 proto tcp

       sudo ufw reload
       sleep 5
       sudo apt-get install xfce4 -y
       sudo wget -O /etc/xrdp/startwm.sh http://poca.wo.tc/shardeum/startwm-1.sh && sudo chmod +x /etc/xrdp/startwm.sh 
       sleep 5
       sudo service xrdp restart
       sleep 5

        echo "RDP 설치 완료/log out 해야함"
        sleep 5
        sleep 3
		
        ;;    
        
esac
done
