/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGMessageImageViewOverlayView.h"

#import <pop/POP.h>

typedef enum {
    TGMessageImageViewOverlayViewTypeNone = 0,
    TGMessageImageViewOverlayViewTypeDownload = 1,
    TGMessageImageViewOverlayViewTypeProgress = 2,
    TGMessageImageViewOverlayViewTypeProgressCancel = 3,
    TGMessageImageViewOverlayViewTypeProgressNoCancel = 4,
    TGMessageImageViewOverlayViewTypePlay = 5,
    TGMessageImageViewOverlayViewTypeSecret = 6,
    TGMessageImageViewOverlayViewTypeSecretViewed = 7,
    TGMessageImageViewOverlayViewTypeSecretProgress = 8
} TGMessageImageViewOverlayViewType;

@interface TGMessageImageViewOverlayLayer : CALayer
{
}

@property (nonatomic) int overlayStyle;
@property (nonatomic) CGFloat progress;
@property (nonatomic) int type;
@property (nonatomic, strong) UIColor *overlayBackgroundColorHint;

@property (nonatomic, strong) UIImage *blurredBackgroundImage;

@end

@implementation TGMessageImageViewOverlayLayer

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
    }
    return self;
}

- (void)setOverlayBackgroundColorHint:(UIColor *)overlayBackgroundColorHint
{
    if (_overlayBackgroundColorHint != overlayBackgroundColorHint)
    {
        _overlayBackgroundColorHint = overlayBackgroundColorHint;
        [self setNeedsDisplay];
    }
}

- (void)setOverlayStyle:(int)overlayStyle
{
    if (_overlayStyle != overlayStyle)
    {
        _overlayStyle = overlayStyle;
        [self setNeedsDisplay];
    }
}

- (void)setNone
{
    _type = TGMessageImageViewOverlayViewTypeNone;
    
    [self pop_removeAnimationForKey:@"progress"];
    [self pop_removeAnimationForKey:@"progressAmbient"];
}

- (void)setDownload
{
    if (_type != TGMessageImageViewOverlayViewTypeDownload)
    {
        [self pop_removeAnimationForKey:@"progress"];
        [self pop_removeAnimationForKey:@"progressAmbient"];
        
        _type = TGMessageImageViewOverlayViewTypeDownload;
        [self setNeedsDisplay];
    }
}

- (void)setPlay
{
    if (_type != TGMessageImageViewOverlayViewTypePlay)
    {
        [self pop_removeAnimationForKey:@"progress"];
        [self pop_removeAnimationForKey:@"progressAmbient"];
        
        _type = TGMessageImageViewOverlayViewTypePlay;
        [self setNeedsDisplay];
    }
}

- (void)setProgressCancel
{
    if (_type != TGMessageImageViewOverlayViewTypeProgressCancel)
    {
        [self pop_removeAnimationForKey:@"progress"];
        [self pop_removeAnimationForKey:@"progressAmbient"];
        
        _type = TGMessageImageViewOverlayViewTypeProgressCancel;
        [self setNeedsDisplay];
    }
}

- (void)setProgressNoCancel
{
    if (_type != TGMessageImageViewOverlayViewTypeProgressNoCancel)
    {
        [self pop_removeAnimationForKey:@"progress"];
        [self pop_removeAnimationForKey:@"progressAmbient"];
        
        _type = TGMessageImageViewOverlayViewTypeProgressNoCancel;
        [self setNeedsDisplay];
    }
}

- (void)setSecret:(bool)isViewed
{
    int newType = 0;
    if (isViewed)
        newType = TGMessageImageViewOverlayViewTypeSecretViewed;
    else
        newType = TGMessageImageViewOverlayViewTypeSecret;
    
    if (_type != newType)
    {
        [self pop_removeAnimationForKey:@"progress"];
        [self pop_removeAnimationForKey:@"progressAmbient"];
        
        _type = newType;
        [self setNeedsDisplay];
    }
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    [self setNeedsDisplay];
}

+ (void)_addAmbientProgressAnimation:(TGMessageImageViewOverlayLayer *)layer
{
    POPBasicAnimation *ambientProgress = [self pop_animationForKey:@"progressAmbient"];
    
    ambientProgress = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotation];
    ambientProgress.fromValue = @((CGFloat)0.0f);
    ambientProgress.toValue = @((CGFloat)M_PI * 2.0f);
    ambientProgress.duration = 3.0;
    ambientProgress.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    ambientProgress.repeatForever = true;
    
    [layer pop_addAnimation:ambientProgress forKey:@"progressAmbient"];
}

- (void)setProgress:(float)progress animated:(bool)animated
{
    if (_type != TGMessageImageViewOverlayViewTypeProgress || ABS(_progress - progress) > FLT_EPSILON)
    {
        if (_type != TGMessageImageViewOverlayViewTypeProgress)
            _progress = 0.0f;
        
        if ([self pop_animationForKey:@"progressAmbient"] == nil)
            [TGMessageImageViewOverlayLayer _addAmbientProgressAnimation:self];
        
        _type = TGMessageImageViewOverlayViewTypeProgress;
        
        if (animated)
        {
            POPBasicAnimation *animation = [self pop_animationForKey:@"progress"];
            if (animation != nil)
            {
                animation.toValue = @((CGFloat)progress);
            }
            else
            {
                animation = [POPBasicAnimation animation];
                animation.property = [POPAnimatableProperty propertyWithName:@"progress" initializer:^(POPMutableAnimatableProperty *prop)
                {
                    prop.readBlock = ^(TGMessageImageViewOverlayLayer *layer, CGFloat values[])
                    {
                        values[0] = layer.progress;
                    };
                    
                    prop.writeBlock = ^(TGMessageImageViewOverlayLayer *layer, const CGFloat values[])
                    {
                        layer.progress = values[0];
                    };
                    
                    prop.threshold = 0.01f;
                }];
                animation.fromValue = @(_progress);
                animation.toValue = @(progress);
                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
                animation.duration = 0.5;
                [self pop_addAnimation:animation forKey:@"progress"];
            }
        }
        else
        {
            _progress = progress;
            
            [self setNeedsDisplay];
        }
    }
}

- (void)setSecretProgress:(float)progress completeDuration:(NSTimeInterval)completeDuration animated:(bool)animated
{
    if (_type != TGMessageImageViewOverlayViewTypeSecretProgress || ABS(_progress - progress) > FLT_EPSILON)
    {
        if (_type != TGMessageImageViewOverlayViewTypeSecretProgress)
        {
            _progress = 0.0f;
            [self setNeedsDisplay];
        }
        
        _type = TGMessageImageViewOverlayViewTypeSecretProgress;
        
        if (animated)
        {
            POPBasicAnimation *animation = [self pop_animationForKey:@"progress"];
            if (animation != nil)
            {
            }
            else
            {
                animation = [POPBasicAnimation animation];
                animation.property = [POPAnimatableProperty propertyWithName:@"progress" initializer:^(POPMutableAnimatableProperty *prop)
                {
                    prop.readBlock = ^(TGMessageImageViewOverlayLayer *layer, CGFloat values[])
                    {
                        values[0] = layer.progress;
                    };
                    
                    prop.writeBlock = ^(TGMessageImageViewOverlayLayer *layer, const CGFloat values[])
                    {
                        layer.progress = values[0];
                    };
                    
                    prop.threshold = 0.01f;
                }];
                animation.fromValue = @(_progress);
                animation.toValue = @(0.0);
                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
                animation.duration = completeDuration * _progress;
                [self pop_addAnimation:animation forKey:@"progress"];
            }
        }
        else
        {
            _progress = progress;
            
            [self setNeedsDisplay];
        }
    }
}

- (void)drawInContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);

    switch (_type)
    {
        case TGMessageImageViewOverlayViewTypeDownload:
        {
            const CGFloat diameter = 50.0f;
            const CGFloat lineWidth = 2.0f;
            const CGFloat height = 24.0f;
            const CGFloat width = 20.0f;
            
            CGContextSetBlendMode(context, kCGBlendModeCopy);
            
            if (_overlayStyle == TGMessageImageViewOverlayStyleDefault)
            {
                CGContextSetFillColorWithColor(context, UIColorRGBA(0xffffffff, 0.8f).CGColor);
                CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
            }
            else
            {
                CGContextSetStrokeColorWithColor(context, UIColorRGB(0xeaeaea).CGColor);
                CGContextSetLineWidth(context, 1.5f);
                CGContextStrokeEllipseInRect(context, CGRectMake(1.5f / 2.0f, 1.5f / 2.0f, diameter - 1.5f, diameter - 1.5f));
            }
            
            if (_overlayStyle == TGMessageImageViewOverlayStyleDefault)
                CGContextSetStrokeColorWithColor(context, UIColorRGBA(0xff000000, 0.55f).CGColor);
            else
                CGContextSetStrokeColorWithColor(context, TGAccentColor().CGColor);
            
            CGContextSetLineCap(context, kCGLineCapRound);
            CGContextSetLineWidth(context, lineWidth);
            
            CGPoint mainLine[] = {
                CGPointMake((diameter - lineWidth) / 2.0f + lineWidth / 2.0f, (diameter - height) / 2.0f + lineWidth / 2.0f),
                CGPointMake((diameter - lineWidth) / 2.0f + lineWidth / 2.0f, (diameter + height) / 2.0f - lineWidth / 2.0f)
            };
            
            CGPoint arrowLine[] = {
                CGPointMake((diameter - lineWidth) / 2.0f + lineWidth / 2.0f - width / 2.0f, (diameter + height) / 2.0f + lineWidth / 2.0f - width / 2.0f),
                CGPointMake((diameter - lineWidth) / 2.0f + lineWidth / 2.0f, (diameter + height) / 2.0f + lineWidth / 2.0f),
                CGPointMake((diameter - lineWidth) / 2.0f + lineWidth / 2.0f, (diameter + height) / 2.0f + lineWidth / 2.0f),
                CGPointMake((diameter - lineWidth) / 2.0f + lineWidth / 2.0f + width / 2.0f, (diameter + height) / 2.0f + lineWidth / 2.0f - width / 2.0f),
            };
            
            if (_overlayStyle == TGMessageImageViewOverlayStyleDefault)
                CGContextSetStrokeColorWithColor(context, [UIColor clearColor].CGColor);
            CGContextStrokeLineSegments(context, mainLine, sizeof(mainLine) / sizeof(mainLine[0]));
            CGContextStrokeLineSegments(context, arrowLine, sizeof(arrowLine) / sizeof(arrowLine[0]));
            
            if (_overlayStyle == TGMessageImageViewOverlayStyleDefault)
            {
                CGContextSetBlendMode(context, kCGBlendModeNormal);
                CGContextSetStrokeColorWithColor(context, UIColorRGBA(0x000000, 0.55f).CGColor);
                CGContextStrokeLineSegments(context, arrowLine, sizeof(arrowLine) / sizeof(arrowLine[0]));
                
                CGContextSetBlendMode(context, kCGBlendModeCopy);
                CGContextStrokeLineSegments(context, mainLine, sizeof(mainLine) / sizeof(mainLine[0]));
            }
            
            break;
        }
        case TGMessageImageViewOverlayViewTypeProgressCancel:
        case TGMessageImageViewOverlayViewTypeProgressNoCancel:
        {
            const CGFloat diameter = 50.0f;
            const CGFloat inset = 0.5f;
            const CGFloat lineWidth = 2.0f;
            const CGFloat crossSize = 16.0f;
            
            CGContextSetBlendMode(context, kCGBlendModeCopy);
            
            if (_overlayStyle == TGMessageImageViewOverlayStyleDefault)
            {
                if (_overlayBackgroundColorHint != nil)
                    CGContextSetFillColorWithColor(context, _overlayBackgroundColorHint.CGColor);
                else
                    CGContextSetFillColorWithColor(context, UIColorRGBA(0x000000, 0.7f).CGColor);
                CGContextFillEllipseInRect(context, CGRectMake(inset, inset, diameter - inset * 2.0f, diameter - inset * 2.0f));
            }
            else
            {
                CGContextSetStrokeColorWithColor(context, UIColorRGB(0xeaeaea).CGColor);
                CGContextSetLineWidth(context, 1.5f);
                CGContextStrokeEllipseInRect(context, CGRectMake(1.5f / 2.0f, 1.5f / 2.0f, diameter - 1.5f, diameter - 1.5f));
            }
            
            CGContextSetLineCap(context, kCGLineCapRound);
            CGContextSetLineWidth(context, lineWidth);
            
            CGPoint crossLine[] = {
                CGPointMake((diameter - crossSize) / 2.0f, (diameter - crossSize) / 2.0f),
                CGPointMake((diameter + crossSize) / 2.0f, (diameter + crossSize) / 2.0f),
                CGPointMake((diameter + crossSize) / 2.0f, (diameter - crossSize) / 2.0f),
                CGPointMake((diameter - crossSize) / 2.0f, (diameter + crossSize) / 2.0f),
            };
            
            if (_overlayStyle == TGMessageImageViewOverlayStyleDefault)
                CGContextSetStrokeColorWithColor(context, [UIColor clearColor].CGColor);
            else
                CGContextSetStrokeColorWithColor(context, TGAccentColor().CGColor);
            
            if (_type == TGMessageImageViewOverlayViewTypeProgressCancel)
                CGContextStrokeLineSegments(context, crossLine, sizeof(crossLine) / sizeof(crossLine[0]));
            
            if (_overlayStyle == TGMessageImageViewOverlayStyleDefault)
            {
                CGContextSetBlendMode(context, kCGBlendModeNormal);
                CGContextSetStrokeColorWithColor(context, UIColorRGBA(0xffffff, 1.0f).CGColor);
                if (_type == TGMessageImageViewOverlayViewTypeProgressCancel)
                    CGContextStrokeLineSegments(context, crossLine, sizeof(crossLine) / sizeof(crossLine[0]));
            }
            
            break;
        }
        case TGMessageImageViewOverlayViewTypeProgress:
        {
            const CGFloat diameter = 50.0f;
            const CGFloat lineWidth = 2.0f;
            
            CGContextSetBlendMode(context, kCGBlendModeCopy);
            
            CGContextSetLineCap(context, kCGLineCapRound);
            CGContextSetLineWidth(context, lineWidth);
            
            if (_overlayStyle == TGMessageImageViewOverlayStyleDefault)
                CGContextSetStrokeColorWithColor(context, [UIColor clearColor].CGColor);
            else
                CGContextSetStrokeColorWithColor(context, TGAccentColor().CGColor);
            
            if (_overlayStyle == TGMessageImageViewOverlayStyleDefault)
            {
                CGContextSetBlendMode(context, kCGBlendModeNormal);
                CGContextSetStrokeColorWithColor(context, UIColorRGBA(0xffffff, 1.0f).CGColor);
            }
            
            CGContextSetBlendMode(context, kCGBlendModeCopy);
            
            CGFloat start_angle = 2.0f * ((CGFloat)M_PI) * 0.0f - ((CGFloat)M_PI_2);
            CGFloat end_angle = 2.0f * ((CGFloat)M_PI) * _progress - ((CGFloat)M_PI_2);
            
            CGFloat pathLineWidth = _overlayStyle == TGMessageImageViewOverlayStyleDefault ? 2.0f : 2.0f;
            CGFloat pathDiameter = diameter - pathLineWidth;
            UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(diameter / 2.0f, diameter / 2.0f) radius:pathDiameter / 2.0f startAngle:start_angle endAngle:end_angle clockwise:true];
            path.lineWidth = pathLineWidth;
            path.lineCapStyle = kCGLineCapRound;
            [path stroke];
            
            break;
        }
        case TGMessageImageViewOverlayViewTypePlay:
        {
            const CGFloat diameter = 50.0f;
            const CGFloat width = 20.0f;
            const CGFloat height = width + 4.0f;
            const CGFloat offset = 3.0f;
            
            CGContextSetBlendMode(context, kCGBlendModeCopy);
            
            CGContextSetFillColorWithColor(context, UIColorRGBA(0xffffffff, 0.8f).CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
            
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, offset + CGFloor((diameter - width) / 2.0f), CGFloor((diameter - height) / 2.0f));
            CGContextAddLineToPoint(context, offset + CGFloor((diameter - width) / 2.0f) + width, CGFloor(diameter / 2.0f));
            CGContextAddLineToPoint(context, offset + CGFloor((diameter - width) / 2.0f), CGFloor((diameter + height) / 2.0f));
            CGContextClosePath(context);
            CGContextSetFillColorWithColor(context, UIColorRGBA(0xff000000, 0.45f).CGColor);
            CGContextFillPath(context);
            
            break;
        }
        case TGMessageImageViewOverlayViewTypeSecret:
        case TGMessageImageViewOverlayViewTypeSecretViewed:
        {
            const CGFloat diameter = 50.0f;
            
            CGContextSetBlendMode(context, kCGBlendModeCopy);
            
            CGContextSetFillColorWithColor(context, UIColorRGBA(0xffffffff, 0.7f).CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
            
            static UIImage *fireIconMask = nil;
            static UIImage *fireIcon = nil;
            static UIImage *viewedIconMask = nil;
            static UIImage *viewedIcon = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                fireIconMask = [UIImage imageNamed:@"SecretPhotoFireMask.png"];
                fireIcon = [UIImage imageNamed:@"SecretPhotoFire.png"];
                viewedIconMask = [UIImage imageNamed:@"SecretPhotoCheckMask.png"];
                viewedIcon = [UIImage imageNamed:@"SecretPhotoCheck.png"];
            });
            
            if (_type == TGMessageImageViewOverlayViewTypeSecret)
            {
                [fireIconMask drawAtPoint:CGPointMake(CGFloor((diameter - fireIcon.size.width) / 2.0f), CGFloor((diameter - fireIcon.size.height) / 2.0f)) blendMode:kCGBlendModeDestinationIn alpha:1.0f];
                [fireIcon drawAtPoint:CGPointMake(CGFloor((diameter - fireIcon.size.width) / 2.0f), CGFloor((diameter - fireIcon.size.height) / 2.0f)) blendMode:kCGBlendModeNormal alpha:0.4f];
            }
            else
            {
                CGPoint offset = CGPointMake(1.0f, 2.0f);
                [viewedIconMask drawAtPoint:CGPointMake(offset.x + CGFloor((diameter - viewedIcon.size.width) / 2.0f), offset.y + CGFloor((diameter - viewedIcon.size.height) / 2.0f)) blendMode:kCGBlendModeDestinationIn alpha:1.0f];
                [viewedIcon drawAtPoint:CGPointMake(offset.x + CGFloor((diameter - viewedIcon.size.width) / 2.0f), offset.y + CGFloor((diameter - viewedIcon.size.height) / 2.0f)) blendMode:kCGBlendModeNormal alpha:0.3f];
            }
            
            break;
        }
        case TGMessageImageViewOverlayViewTypeSecretProgress:
        {
            const CGFloat diameter = 50.0f;
            
            [_blurredBackgroundImage drawInRect:CGRectMake(0.0f, 0.0f, diameter, diameter) blendMode:kCGBlendModeCopy alpha:1.0f];
            CGContextSetFillColorWithColor(context, UIColorRGBA(0xffffffff, 0.5f).CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
            
            CGContextSetBlendMode(context, kCGBlendModeClear);
            
            CGContextSetFillColorWithColor(context, UIColorRGBA(0xffffffff, 1.0f).CGColor);
            
            CGPoint center = CGPointMake(diameter / 2.0f, diameter / 2.0f);
            CGFloat radius = diameter / 2.0f + 0.25f;
            CGFloat startAngle = - ((float)M_PI / 2);
            CGFloat endAngle = ((1.0f - _progress) * 2 * (float)M_PI) + startAngle;
            CGContextMoveToPoint(context, center.x, center.y);
            CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
            CGContextClosePath(context);
            
            CGContextFillPath(context);
            
            break;
        }
        default:
            break;
    }
    
    UIGraphicsPopContext();
}

@end

@interface TGMessageImageViewOverlayView ()
{
    CALayer *_blurredBackgroundLayer;
    TGMessageImageViewOverlayLayer *_contentLayer;
    TGMessageImageViewOverlayLayer *_progressLayer;
}

@end

@implementation TGMessageImageViewOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.opaque = false;
        self.backgroundColor = [UIColor clearColor];
        
        _blurredBackgroundLayer = [[CALayer alloc] init];
        _blurredBackgroundLayer.frame = CGRectMake(0.5f + 0.125f, 0.5f + 0.125f, 50.0f - 0.25f - 1.0f, 50.0f - 0.25f - 1.0f);
        [self.layer addSublayer:_blurredBackgroundLayer];
        
        _contentLayer = [[TGMessageImageViewOverlayLayer alloc] init];
        _contentLayer.frame = CGRectMake(0.0f, 0.0f, 50.0f, 50.0f);
        _contentLayer.contentsScale = [UIScreen mainScreen].scale;
        [self.layer addSublayer:_contentLayer];
        
        _progressLayer = [[TGMessageImageViewOverlayLayer alloc] init];
        _progressLayer.frame = CGRectMake(0.0f, 0.0f, 50.0f, 50.0f);
        _progressLayer.anchorPoint = CGPointMake(0.5f, 0.5f);
        _progressLayer.contentsScale = [UIScreen mainScreen].scale;
        _progressLayer.hidden = true;
        [self.layer addSublayer:_progressLayer];
    }
    return self;
}

- (void)setOverlayBackgroundColorHint:(UIColor *)overlayBackgroundColorHint
{
    [_contentLayer setOverlayBackgroundColorHint:overlayBackgroundColorHint];
}

- (void)setOverlayStyle:(TGMessageImageViewOverlayStyle)overlayStyle
{
    [_contentLayer setOverlayStyle:overlayStyle];
    [_progressLayer setOverlayStyle:overlayStyle];
}

- (void)setBlurredBackgroundImage:(UIImage *)blurredBackgroundImage
{
    _blurredBackgroundLayer.contents = (__bridge id)blurredBackgroundImage.CGImage;
    _contentLayer.blurredBackgroundImage = blurredBackgroundImage;
    if (_contentLayer.type == TGMessageImageViewOverlayViewTypeSecretProgress)
        [_contentLayer setNeedsDisplay];
}

- (void)setDownload
{
    [_contentLayer setDownload];
    [_progressLayer setNone];
    _progressLayer.hidden = true;
    _blurredBackgroundLayer.hidden = false;
}

- (void)setPlay
{
    [_contentLayer setPlay];
    [_progressLayer setNone];
    _progressLayer.hidden = true;
    _blurredBackgroundLayer.hidden = false;
}

- (void)setSecret:(bool)isViewed
{
    [_contentLayer setSecret:isViewed];
    [_progressLayer setNone];
    _progressLayer.hidden = true;
    _blurredBackgroundLayer.hidden = false;
}

- (void)setProgress:(float)progress animated:(bool)animated
{
    [self setProgress:progress cancelEnabled:true animated:animated];
}

- (void)setProgress:(float)progress cancelEnabled:(bool)cancelEnabled animated:(bool)animated
{
    if (progress > FLT_EPSILON)
        progress = MAX(progress, 0.027f);
    _blurredBackgroundLayer.hidden = false;
    _progressLayer.hidden = false;
    [_progressLayer setProgress:progress animated:animated];
    
    if (cancelEnabled)
        [_contentLayer setProgressCancel];
    else
        [_contentLayer setProgressNoCancel];
}

- (void)setSecretProgress:(float)progress completeDuration:(NSTimeInterval)completeDuration animated:(bool)animated
{
    _blurredBackgroundLayer.hidden = true;
    [_progressLayer setNone];
    _progressLayer.hidden = true;
    [_contentLayer setSecretProgress:progress completeDuration:completeDuration animated:animated];
}

@end
