//
//  KashrutGameTypes.h
//  iReacTIVision
//
//  Created by Markus Konrad on 25.02.12.
//  Copyright (c) 2012 Markus Konrad <post@mkonrad.net>. Licensed under GPL.
//

#ifndef iReacTIVision_KashrutGameTypes_h
#define iReacTIVision_KashrutGameTypes_h

typedef enum {
    kKashrutGameFoodTypeUnknown = -1,
    kKashrutGameFoodTypeDairy = 0,
    kKashrutGameFoodTypeMeat,
    kKashrutGameFoodTypeNeutral,
    kKashrutGameFoodTypeUnkosher
} KashrutGameFoodType;

//typedef enum {
//    kKashrutFoodObjectStatusUnknown = -1,
//    kKashrutFoodObjectStatusInvalid,
//    kKashrutFoodObjectStatusValid
//} KashrutFoodObjectStatus;

#endif
