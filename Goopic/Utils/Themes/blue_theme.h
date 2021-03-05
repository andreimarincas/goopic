//
//  blue_theme.h
//  Goopic
//
//  Created by andrei.marincas on 18/09/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#ifndef Goopic_blue_theme_h
#define Goopic_blue_theme_h

#define GPBUTTON_COLOR                    GPCOLOR_BLUE_TEXT
#define GPBUTTON_COLOR_PRESSED            [GPCOLOR_BLUE_TEXT colorWithAlphaComponent:0.35f]

#define GPTOOLBAR_BACKGROUND_COLOR        [UIColor colorWithWhite:0.9f alpha:0.85f]
#define GPTOOLBAR_TITLE_COLOR             GPCOLOR_DARK_BLACK
#define GPTOOLBAR_LINE_COLOR              [UIColor colorWithWhite:0.3f alpha:1.0f]

#define GPTOOLBAR_TITLE_FONT              @"Helvetica"

#define STATUS_BAR_STYLE                  UIStatusBarStyleDefault

#define PHOTOS_TABLE_BACKGROUND_COLOR     [UIColor whiteColor]
#define PHOTOS_TABLE_BORDER_COLOR         [UIColor whiteColor]

#define PHOTOS_SPACING                    1.0f

#define DATE_COLOR                        GPCOLOR_DARK_BLACK
#define DATE_FONT                         [UIFont fontWithName:@"Helvetica" size:13.0f]

#define PHOTO_VIEW_BACKGROUND_COLOR       [UIColor whiteColor]
#define PHOTO_VIEW_FULLSCREEN_COLOR       [UIColor whiteColor]

#define ACTIVITY_VIEW_BACKGROUND_COLOR    GPCOLOR_TRANSLUCENT_DARK
#define ACTIVITY_VIEW_TEXT_COLOR          GPCOLOR_WHITE
#define ACTIVITY_VIEW_STYLE               UIActivityIndicatorViewStyleWhite

#define CAMERA_VIEW_BUTTON_COLOR          GPCOLOR_BLUE
#define CAMERA_VIEW_BUTTON_COLOR_PRESSED  [GPCOLOR_BLUE_TEXT colorWithAlphaComponent:0.35f]
#define CAMERA_VIEW_FLASH_SELECTION_COLOR GPCOLOR_ORANGE_SELECTED

#define CAMERA_VIEW_BACKGROUND_COLOR      GPCOLOR_DARK_BLACK
#define CAMERA_TOOLBAR_LINE_COLOR         [UIColor clearColor]

#endif
