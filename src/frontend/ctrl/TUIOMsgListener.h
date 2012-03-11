//
//  TUIOMsgListener.h
//  iReacTIVision
//
//  Created by Markus Konrad on 23.02.12.
//  Copyright (c) 2012 Markus Konrad <post@mkonrad.net>. Licensed under GPL.
//

#include "OscPacketListener.h"

#ifndef iReacTIVision_TUIOMsgListener_h
#define iReacTIVision_TUIOMsgListener_h

// TUIO message format of protocol version 1.1.

typedef enum {  // message type
    kTUIOMsgTypeObj = 0,    // tagged object
    kTUIOMsgTypeCur,        // cursor / touch
    kTUIOMsgTypeBlb         // blob
} TUIOMsgType;


typedef enum {  // message command
    kTUIOMsgCmdSrc = 0,     // message source
    kTUIOMsgCmdAlive,       // alive message with list of session ids for each recognized object
    kTUIOMsgCmdSet,         // set message with session id and further parameters for this object
    kTUIOMsgCmdFSeq         // unique frame sequence number
} TUIOMsgCmd;

typedef struct {    // 2d vector
    float x;
    float y;
} TUIOMsgVec;

// TUIO message for each object type and command
typedef struct _TUIOMsg {
    TUIOMsgType type;   // type can be "obj" (tagged object), "cur" (cursor/touch) or "blb" (blob)
    TUIOMsgCmd cmd;     // command can be "source", "alive", "set" or "fseq"
    union _data {
        struct {    // for cmd = "source"
            char * addr;    // string with source host
        } source;
        struct {    // for cmd = "alive"
            int * sessIds;  // array with length of "numSessIds"
            unsigned int numSessIds;    // number of session ids
        } alive;
        struct {    // for cmd = "set"
            int sessId;         // session id
            int classId;        // fiducial marker id
            TUIOMsgVec pos;
            float angle;
            TUIOMsgVec size;
            float area;
            TUIOMsgVec vel;
            float angleVel;
            float motAccel;
            float rotAccel;
        } set;
        struct {    // for cmd = "fseq"
            int frameId;    // unique frame seq. number
        } fseq;
    } data;
    
    _TUIOMsg() {
        memset(this, 0, sizeof(_TUIOMsg));
    };
    
    ~_TUIOMsg() {
        if (cmd == kTUIOMsgCmdSrc && data.source.addr) {
            delete [] data.source.addr;
            data.source.addr = NULL;
        } else if (cmd == kTUIOMsgCmdAlive && data.alive.sessIds) {
            delete [] data.alive.sessIds;
            data.alive.sessIds = NULL;
        }
    };
} TUIOMsg;

typedef void(*TUIOMsgCallback)(TUIOMsg *);

class TUIOMsgListener : public osc::OscPacketListener {

public:
    TUIOMsgListener(TUIOMsgCallback callback);
    void setTUIOAddressPrefix(const char *newPrefix);

protected:
    virtual void ProcessMessage(const osc::ReceivedMessage& m, const IpEndpointName& remoteEndpoint);
    
private:
    TUIOMsgCallback msgCallback;
    const char *tuioAddressPrefix;
};

#endif
