//
//  TUIOMsgListener.cpp
//  iReacTIVision
//
//  Created by Markus Konrad on 23.02.12.
//  Copyright (c) 2012 Markus Konrad <post@mkonrad.net>. Licensed under GPL.
//

#include <iostream>

#include "TUIOMsgListener.h"

TUIOMsgListener::TUIOMsgListener(TUIOMsgCallback callback) :
    msgCallback(callback),
    tuioAddressPrefix("/tuio") {
    
}

void TUIOMsgListener::setTUIOAddressPrefix(const char *newPrefix) {
    tuioAddressPrefix = newPrefix;
}

void TUIOMsgListener::ProcessMessage(const osc::ReceivedMessage &m, const IpEndpointName &remoteEndpoint) {
    try {
        const char *addr = m.AddressPattern();
        
        std::cout << "TUIOMsgListener: Received message "
            << addr << std::endl;
            
        const int prefixLen = strlen(tuioAddressPrefix);
        
        if (strncmp(addr, tuioAddressPrefix, prefixLen) == 0 && strlen(addr) > prefixLen + 1) {
            TUIOMsg *msg = new TUIOMsg;
            const char *type = (addr + prefixLen + 1);
            osc::ReceivedMessage::const_iterator arg = m.ArgumentsBegin();
            const unsigned long numArgs = m.ArgumentCount();

            if (strcmp(type, "2Dobj") == 0) {
                msg->type = kTUIOMsgTypeObj;
            } else if (strcmp(type, "2Dcur") == 0) {
                msg->type = kTUIOMsgTypeCur;
            } else if (strcmp(type, "2Dblb") == 0) {
                msg->type = kTUIOMsgTypeBlb;
            } else {
                std::cerr << "TUIOMsgListener: unknown TUIO message type "
                    << type << std::endl;
                return;
            }
            
            const char *cmd = (arg++)->AsString();

            if (strcmp(cmd, "source") == 0) {
                msg->cmd = kTUIOMsgCmdSrc;
            } else if (strcmp(cmd, "alive") == 0) {
                msg->cmd = kTUIOMsgCmdAlive;
            } else if (strcmp(cmd, "set") == 0) {
                msg->cmd = kTUIOMsgCmdSet;
            } else if (strcmp(cmd, "fseq") == 0) {
                msg->cmd = kTUIOMsgCmdFSeq;
            } else {
                std::cerr << "TUIOMsgListener: unknown TUIO message command "
                    << cmd << std::endl;
                return;
            }
            
            switch (msg->cmd) {
                case kTUIOMsgCmdSrc: {
                    const char *srcAddr = (arg++)->AsString();
                    const int addrLen = strlen(srcAddr + 1);
                    msg->data.source.addr = new char[addrLen];
                    strncpy(msg->data.source.addr, srcAddr, addrLen);
                }
                break;

                case kTUIOMsgCmdAlive: {
                    msg->data.alive.numSessIds = numArgs - 1;
                    if (msg->data.alive.numSessIds > 0) {
                        msg->data.alive.sessIds = new int[msg->data.alive.numSessIds];
                        
                        for (int i = 0; i < msg->data.alive.numSessIds; i++) {
                            msg->data.alive.sessIds[i] = (arg++)->AsInt32();
                        }
                    } else {
                        msg->data.alive.sessIds = NULL;
                    }
                }
                break;
                
                case kTUIOMsgCmdSet: {
                    msg->data.set.sessId = (arg++)->AsInt32();
                
                    switch (msg->type) {
                        case kTUIOMsgTypeObj:
                            msg->data.set.classId = (arg++)->AsInt32();
                            msg->data.set.pos.x = (arg++)->AsFloat();
                            msg->data.set.pos.y = (arg++)->AsFloat();
                            msg->data.set.angle = (arg++)->AsFloat();
                            msg->data.set.size.x = 0.0f;
                            msg->data.set.size.y = 0.0f;
                            msg->data.set.area = 0.0f;
                            msg->data.set.vel.x = (arg++)->AsFloat();
                            msg->data.set.vel.y = (arg++)->AsFloat();
                            msg->data.set.angleVel = (arg++)->AsFloat();
                            msg->data.set.motAccel = (arg++)->AsFloat();
                            msg->data.set.rotAccel = (arg++)->AsFloat();
                        break;
                        
                        case kTUIOMsgTypeCur:
                            msg->data.set.classId = 0;
                            msg->data.set.pos.x = (arg++)->AsFloat();
                            msg->data.set.pos.y = (arg++)->AsFloat();
                            msg->data.set.angle = 0.0f;
                            msg->data.set.size.x = 0.0f;
                            msg->data.set.size.y = 0.0f;
                            msg->data.set.area = 0.0f;
                            msg->data.set.vel.x = (arg++)->AsFloat();
                            msg->data.set.vel.y = (arg++)->AsFloat();
                            msg->data.set.angleVel = 0.0f;
                            msg->data.set.motAccel = (arg++)->AsFloat();
                            msg->data.set.rotAccel = 0.0f;
                        break;
                        
                        case kTUIOMsgTypeBlb:
                            msg->data.set.classId = 0;
                            msg->data.set.pos.x = (arg++)->AsFloat();
                            msg->data.set.pos.y = (arg++)->AsFloat();
                            msg->data.set.angle = (arg++)->AsFloat();
                            msg->data.set.size.x = (arg++)->AsFloat();
                            msg->data.set.size.y = (arg++)->AsFloat();
                            msg->data.set.area = 0.0f;
                            msg->data.set.vel.x = (arg++)->AsFloat();
                            msg->data.set.vel.y = (arg++)->AsFloat();
                            msg->data.set.angleVel = (arg++)->AsFloat();
                            msg->data.set.motAccel = (arg++)->AsFloat();
                            msg->data.set.rotAccel = (arg++)->AsFloat();
                        break;
                    }
                }   
                break;
                
                case kTUIOMsgCmdFSeq: {
                    msg->data.fseq.frameId = (arg++)->AsInt32();
                }
                break;
            }
            
            if (msgCallback) {
                msgCallback(msg);
            }
        } else {
            std::cerr << "TUIOMsgListener: Address prefix " << addr << " did not match to "
                << tuioAddressPrefix << std::endl;
        }
    } catch( osc::Exception& e ){
        // any parsing errors such as unexpected argument types, or
        // missing arguments get thrown as exceptions.
        std::cerr << "TUIOMsgListener: error while parsing message "
            << m.AddressPattern() << ": " << e.what() << "\n";
    }
}