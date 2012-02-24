//
//  TUIOMsgListener.h
//  iReacTIVision
//
//  Created by Markus Konrad on 23.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include "OscPacketListener.h"

#ifndef iReacTIVision_TUIOMsgListener_h
#define iReacTIVision_TUIOMsgListener_h

typedef enum {
    kTUIOMsgTypeObj = 0,
    kTUIOMsgTypeCur,
    kTUIOMsgTypeBlb
} TUIOMsgType;

typedef enum {
    kTUIOMsgCmdSrc = 0,
    kTUIOMsgCmdAlive,
    kTUIOMsgCmdSet,
    kTUIOMsgCmdFSeq
} TUIOMsgCmd;

typedef struct {
    float x;
    float y;
} TUIOMsgVec;

typedef struct _TUIOMsg {
    TUIOMsgType type;
    TUIOMsgCmd cmd;
    union _data {
        struct {    // for cmd = "source"
            char * addr;
        } source;
        struct {    // for cmd = "alive"
            int * sessIds;
            unsigned int numSessIds;
        } alive;
        struct {    // for cmd = "set"
            int sessId;
            int classId;
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
            int frameId;
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

typedef void(*TUIOMsgCallback)(TUIOMsg);

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
