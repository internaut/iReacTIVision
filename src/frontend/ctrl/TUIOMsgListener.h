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

typedef const char*(*TUIOMsgCallback)(void);

class TUIOMsgListener : public osc::OscPacketListener {

public:
    TUIOMsgListener(TUIOMsgCallback callback);

protected:
    virtual void ProcessMessage(const osc::ReceivedMessage& m, const IpEndpointName& remoteEndpoint);
    
private:
    TUIOMsgCallback msgCallback;
    
};

#endif
