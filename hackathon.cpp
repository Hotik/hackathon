#include "SX1272.h"
#include <stdio.h>
#include <getopt.h>
#include <stdlib.h>
#include <unistd.h>
#include <termios.h>
#include  <signal.h>
#include <sys/time.h>
#include <time.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include "sqlite3.h"

// Define section

#define BAND868 //900, 433
#define MAX_NB_CHANNEL 9
#define STARTING_CHANNEL 10
#define ENDING_CHANNEL 18
uint8_t loraChannelIndex=0;
uint32_t loraChannelArray[MAX_NB_CHANNEL]={CH_10_868,CH_11_868,CH_12_868,CH_13_868,CH_14_868,CH_15_868,CH_16_868,CH_17_868,CH_18_868};
#define LORAMODE  1 //Mode
#define LORA_ADDR 255 //Self address
#define DEFAULT_DEST_ADDR 6 //Gateway address

  #define PRINTLN                   printf("\n")
  #define PRINT_CSTSTR(fmt,param)   printf(fmt,param)
  #define PRINT_STR(fmt,param)      PRINT_CSTSTR(fmt,param)
  #define PRINT_VALUE(fmt,param)    PRINT_CSTSTR(fmt,param)
  #define FLUSHOUTPUT               fflush(stdout);


#define ARD_NUM 1
#define TIMER_RETRY 5000
#define TIMER 50000
//Variales
int ard_arr[ARD_NUM] = {0};
int dest_addr=DEFAULT_DEST_ADDR;
char cmd[260]="****************";
char sprintf_buf[100];
int msg_sn=0;
bool radioON=false;
uint8_t loraMode=LORAMODE;
uint32_t loraChannel=loraChannelArray[loraChannelIndex];
char loraPower='x'; //innitial poser level, M (maximum), H (high), L (low)
uint8_t loraAddr=LORA_ADDR;
unsigned int inter_pkt_time=10000; //Time between sending
unsigned int random_inter_pkt_time=0;
long last_periodic_sendtime=0;
// packet size for periodic sending
uint8_t MSS=40;
int ST=0;

int Gi=0;
int book=0;
int zero=0;


void UpdateDB(int id, int percent)
{

    int rc;
    char *error;
    sqlite3 *db;
    rc = sqlite3_open("trash.db", &db);

	  char *sqlUpdateTable=new char[60];//malloc(60);
    sprintf(sqlUpdateTable,"Update Trash Set percent = %d where id=%d;",percent,id);
    printf("\n\n update %d \n\n",status);
    rc = sqlite3_exec(db, sqlUpdateTable, NULL, NULL, &error);

    sqlite3_close(db);
    PRINT_STRa("%s", "DATABASE UPDATE");
}


//Configure LoRa tranciever
void startConfig() {

  int e;

  // Set transmission mode and print the result
  e = sx1272.setMode(loraMode);
  // Select frequency channel
  if (loraMode==11) {
    e = sx1272.setChannel(CH_18_868);
  }
  else {
    e = sx1272.setChannel(loraChannel);
  }
  // Select output power (Max, High or Low)
  e = sx1272.setPower(loraPower);
  // get preamble length
  e = sx1272.getPreambleLength();
  // Set the node address and print the result
  //e = sx1272.setNodeAddress(loraAddr);
  sx1272._nodeAddress=loraAddr;
  e=0;
}

void setup() {
  int e;

  //Add our code here
  Serial.begin(38400);
  // Power ON the module
  e = sx1272.ON();

  PRINT_CSTSTR("%s","^$**********Power ON: state ");
  PRINT_VALUE("%d", e);
  PRINTLN;

  e = sx1272.getSyncWord();

  if (!e) {
    PRINT_CSTSTR("%s","^$Default sync word: 0x");
    PRINT_VALUE("%X", sx1272._syncWord);
    PRINTLN;

  }

  if (!e) {
    radioON=true;
    startConfig();
  }

  FLUSHOUTPUT;
  delay(1000);
printf("setup finished   333331\n\n\n\n");
}


void send_data(int adr, int packet_type)
{
  if (radioON)
  {
        PRINT_CSTSTR("%s", "SEND DATA");
        sx1272.CarrierSense();
        char tmp[1];
        tmp[0] = packet_type;
        int e = sx1272.sendPacketTimeout(adr, (uint8_t*)tmp , strlen(tmp), 1000);
  }
}

int get_data()
{
  uint16_t w_timer = 5000;
  int e = sx1272.receivePacketTimeout(w_timer);
  if (!e)
  {
    int ind = 0;
    int data = 0;
    sx1272.getSNR();
    sx1272.getRSSIpacket();
    tmp_length=sx1272._payloadlength;

    sscanf(sx1272.packet_received.data, "%d %d", &ind, &data);
    PRINT_STR("%s", "GET DATA");
    UpdateDB(ind, data);
    return 0;
  }
  return 1;
}

void loop()
 {

  if (radioON)
  {
    send_data(DEFAULT_DEST_ADDR, 0);
    int wait_data = 1;
    while (wait_data)
    {
      wait_data = get_data();
    }
    send_data(DEFAULT_DEST_ADDR, 1);
    delay(10);

  }
}


int main (int argc, char *argv[]){

  setup();
  while(1){
    loop();
  }

  return (0);
}
