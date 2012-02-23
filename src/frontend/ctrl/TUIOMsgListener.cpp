//
//  TUIOMsgListener.cpp
//  iReacTIVision
//
//  Created by Markus Konrad on 23.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include <iostream>

#include "TUIOMsgListener.h"

TUIOMsgListener::TUIOMsgListener(TUIOMsgCallback callback) :
    msgCallback(callback) {
    
}

void TUIOMsgListener::ProcessMessage(const osc::ReceivedMessage &m, const IpEndpointName &remoteEndpoint) {
    try{
        std::cout << "TUIOMsgListener: Received message "
            << m.AddressPattern() << std::endl;
    
//        // example of parsing single messages. osc::OscPacketListener
//        // handles the bundle traversal.
//        if( strcmp( m.AddressPattern(), "/test1" ) == 0 ){
//            // example #1 -- argument stream interface
//            osc::ReceivedMessageArgumentStream args = m.ArgumentStream();
//            bool a1;
//            osc::int32 a2;
//            float a3;
//            const char *a4;
//            args >> a1 >> a2 >> a3 >> a4 >> osc::EndMessage;
//
//            std::cout << "received '/test1' message with arguments: "
//                << a1 << " " << a2 << " " << a3 << " " << a4 << "\n";                              
//
//        }else if( strcmp( m.AddressPattern(), "/test2" ) == 0 ){
//            // example #2 -- argument iterator interface, supports
//            // reflection for overloaded messages (eg you can call
//            // (*arg)->IsBool() to check if a bool was passed etc).
//
//            osc::ReceivedMessage::const_iterator arg = m.ArgumentsBegin();
//            bool a1 = (arg++)->AsBool();
//            int a2 = (arg++)->AsInt32();
//            float a3 = (arg++)->AsFloat();
//            const char *a4 = (arg++)->AsString();
//            if( arg != m.ArgumentsEnd() )
//                throw osc::ExcessArgumentException();
//
//            std::cout << "received '/test2' message with arguments: "
//                << a1 << " " << a2 << " " << a3 << " " << a4 << "\n";
//        }
    }catch( osc::Exception& e ){
        // any parsing errors such as unexpected argument types, or
        // missing arguments get thrown as exceptions.
        std::cerr << "TUIOMsgListener: error while parsing message "
            << m.AddressPattern() << ": " << e.what() << "\n";
    }
}