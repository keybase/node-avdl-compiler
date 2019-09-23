// Auto-generated to Go types and interfaces using avdl-compiler v1.4.2 (https://github.com/keybase/node-avdl-compiler)
//   Input file: avdl/sample.avdl

package sample1

import (
	"github.com/keybase/go-framed-msgpack-rpc/rpc"
	context "golang.org/x/net/context"
	keybase1 "github.com/keybase/client/go/protocol/keybase1"
	"errors"
)


// Joe is an alias for an int.
type Joe int
func (o Joe) DeepCopy() Joe {
	return o
}

// R is a rad record.
type R struct {
	Bar	keybase1.UID	`codec:"bar" json:"bar"`
	Baz	keybase1.UID	`codec:"baz" json:"baz_j_uid"`
	Woop	string	`codec:"woop,omitempty" json:"woop,omitempty"`
}

func (o R) DeepCopy() R {
	return R{
		Bar: o.Bar.DeepCopy(),
		Baz: o.Baz.DeepCopy(),
		Woop: o.Woop,
	}
}

type Types int
const (
	Types_NONE Types = 0
	Types_BOZO Types = 1
	Types_BIPPY Types = 2
	Types_AGGLE Types = 3
	Types_FLAGGLE Types = 4
)

func (o Types) DeepCopy() Types { return o }
var TypesMap = map[string]Types{
	"NONE": 0,
	"BOZO": 1,
	"BIPPY": 2,
	"AGGLE": 3,
	"FLAGGLE": 4,
}

var TypesRevMap = map[Types]string{
	0: "NONE",
	1: "BOZO",
	2: "BIPPY",
	3: "AGGLE",
	4: "FLAGGLE",
}

func (e Types) String() string {
	if v, ok := TypesRevMap[e]; ok {
		return v
	}
	return ""
}

type EnumNoString int
const (
	EnumNoString_NOSTRING EnumNoString = 0
)

func (o EnumNoString) DeepCopy() EnumNoString { return o }
var EnumNoStringMap = map[string]EnumNoString{
	"NOSTRING": 0,
}

var EnumNoStringRevMap = map[EnumNoString]string{
	0: "NOSTRING",
}

type Boozle struct {
	Typ__	Types	`codec:"typ" json:"typ"`
	Bozo__	*int	`codec:"bozo,omitempty" json:"bozo,omitempty"`
	Bippy__	*string	`codec:"bippy,omitempty" json:"bippy,omitempty"`
	Aggle__	*[]int	`codec:"aggle,omitempty" json:"aggle,omitempty"`
	Flaggle__	*[]bool	`codec:"flaggle,omitempty" json:"flaggle,omitempty"`
	Default__	*int	`codec:"default,omitempty" json:"default,omitempty"`
}

func (o *Boozle) Typ() (ret Types, err error) {
	switch (o.Typ__) {
		case Types_BOZO:
			if o.Bozo__ == nil {
				err = errors.New("unexpected nil value for Bozo__")
				return ret, err
			}
		case Types_BIPPY:
			if o.Bippy__ == nil {
				err = errors.New("unexpected nil value for Bippy__")
				return ret, err
			}
		case Types_AGGLE:
			if o.Aggle__ == nil {
				err = errors.New("unexpected nil value for Aggle__")
				return ret, err
			}
		case Types_FLAGGLE:
			if o.Flaggle__ == nil {
				err = errors.New("unexpected nil value for Flaggle__")
				return ret, err
			}
		default:
			if o.Default__ == nil {
				err = errors.New("unexpected nil value for Default__")
				return ret, err
			}
	}
	return o.Typ__, nil
}

func (o Boozle) Bozo() (res int) {
	if o.Typ__ != Types_BOZO {
		panic("wrong case accessed")
	}
	if o.Bozo__ == nil {
		return
	}
	return *o.Bozo__
}

func (o Boozle) Bippy() (res string) {
	if o.Typ__ != Types_BIPPY {
		panic("wrong case accessed")
	}
	if o.Bippy__ == nil {
		return
	}
	return *o.Bippy__
}

func (o Boozle) Aggle() (res []int) {
	if o.Typ__ != Types_AGGLE {
		panic("wrong case accessed")
	}
	if o.Aggle__ == nil {
		return
	}
	return *o.Aggle__
}

func (o Boozle) Flaggle() (res []bool) {
	if o.Typ__ != Types_FLAGGLE {
		panic("wrong case accessed")
	}
	if o.Flaggle__ == nil {
		return
	}
	return *o.Flaggle__
}

func (o Boozle) Default() (res int) {
	if o.Typ__ == Types_BOZO || o.Typ__ == Types_BIPPY || o.Typ__ == Types_AGGLE || o.Typ__ == Types_FLAGGLE {
		panic("wrong case accessed")
	}
	if o.Default__ == nil {
		return
	}
	return *o.Default__
}

func NewBoozleWithBozo(v int) Boozle {
	return Boozle{
		Typ__ : Types_BOZO,
		Bozo__ : &v,
	}
}

func NewBoozleWithBippy(v string) Boozle {
	return Boozle{
		Typ__ : Types_BIPPY,
		Bippy__ : &v,
	}
}

func NewBoozleWithAggle(v []int) Boozle {
	return Boozle{
		Typ__ : Types_AGGLE,
		Aggle__ : &v,
	}
}

func NewBoozleWithFlaggle(v []bool) Boozle {
	return Boozle{
		Typ__ : Types_FLAGGLE,
		Flaggle__ : &v,
	}
}

func NewBoozleDefault(typ Types, v int) Boozle {
	return Boozle{
		Typ__ : typ,
		Default__ : &v,
	}
}

func (o Boozle) DeepCopy() Boozle {
	return Boozle {
		Typ__: o.Typ__.DeepCopy(),
		Bozo__: (func (x *int) *int {
			if x == nil {
				return nil
			}
			tmp := (*x)
			return &tmp
		})(o.Bozo__),
		Bippy__: (func (x *string) *string {
			if x == nil {
				return nil
			}
			tmp := (*x)
			return &tmp
		})(o.Bippy__),
		Aggle__: (func (x *[]int) *[]int {
			if x == nil {
				return nil
			}
			tmp := (func (x []int) []int {
				if x == nil {
					return nil
				}
				ret := make([]int, len(x))
				for i, v := range x {
					vCopy := v
					ret[i] = vCopy
				}
				return ret
			})((*x))
			return &tmp
		})(o.Aggle__),
		Flaggle__: (func (x *[]bool) *[]bool {
			if x == nil {
				return nil
			}
			tmp := (func (x []bool) []bool {
				if x == nil {
					return nil
				}
				ret := make([]bool, len(x))
				for i, v := range x {
					vCopy := v
					ret[i] = vCopy
				}
				return ret
			})((*x))
			return &tmp
		})(o.Flaggle__),
		Default__: (func (x *int) *int {
			if x == nil {
				return nil
			}
			tmp := (*x)
			return &tmp
		})(o.Default__),
	}
}

type Trixie struct {
	Typ__	Types	`codec:"typ" json:"typ"`
	Bippy__	*int	`codec:"bippy,omitempty" json:"bippy,omitempty"`
	Flaggle__	*EnumNoString	`codec:"flaggle,omitempty" json:"flaggle,omitempty"`
}

func (o *Trixie) Typ() (ret Types, err error) {
	switch (o.Typ__) {
		case Types_BIPPY:
			if o.Bippy__ == nil {
				err = errors.New("unexpected nil value for Bippy__")
				return ret, err
			}
		case Types_FLAGGLE:
			if o.Flaggle__ == nil {
				err = errors.New("unexpected nil value for Flaggle__")
				return ret, err
			}
	}
	return o.Typ__, nil
}

func (o Trixie) Bippy() (res int) {
	if o.Typ__ != Types_BIPPY {
		panic("wrong case accessed")
	}
	if o.Bippy__ == nil {
		return
	}
	return *o.Bippy__
}

func (o Trixie) Flaggle() (res EnumNoString) {
	if o.Typ__ != Types_FLAGGLE {
		panic("wrong case accessed")
	}
	if o.Flaggle__ == nil {
		return
	}
	return *o.Flaggle__
}

func NewTrixieWithNone() Trixie {
	return Trixie{
		Typ__ : Types_NONE,
	}
}

func NewTrixieWithBozo() Trixie {
	return Trixie{
		Typ__ : Types_BOZO,
	}
}

func NewTrixieWithBippy(v int) Trixie {
	return Trixie{
		Typ__ : Types_BIPPY,
		Bippy__ : &v,
	}
}

func NewTrixieWithAggle() Trixie {
	return Trixie{
		Typ__ : Types_AGGLE,
	}
}

func NewTrixieWithFlaggle(v EnumNoString) Trixie {
	return Trixie{
		Typ__ : Types_FLAGGLE,
		Flaggle__ : &v,
	}
}

func (o Trixie) DeepCopy() Trixie {
	return Trixie {
		Typ__: o.Typ__.DeepCopy(),
		Bippy__: (func (x *int) *int {
			if x == nil {
				return nil
			}
			tmp := (*x)
			return &tmp
		})(o.Bippy__),
		Flaggle__: (func (x *EnumNoString) *EnumNoString {
			if x == nil {
				return nil
			}
			tmp := (*x).DeepCopy()
			return &tmp
		})(o.Flaggle__),
	}
}

type Noozle struct {
	Version__	int	`codec:"version" json:"version"`
	Int1__	*string	`codec:"int1,omitempty" json:"int1,omitempty"`
	Int2__	*int	`codec:"int2,omitempty" json:"int2,omitempty"`
}

func (o *Noozle) Version() (ret int, err error) {
	switch (o.Version__) {
		case 1:
			if o.Int1__ == nil {
				err = errors.New("unexpected nil value for Int1__")
				return ret, err
			}
		case 2:
			if o.Int2__ == nil {
				err = errors.New("unexpected nil value for Int2__")
				return ret, err
			}
	}
	return o.Version__, nil
}

func (o Noozle) Int1() (res string) {
	if o.Version__ != 1 {
		panic("wrong case accessed")
	}
	if o.Int1__ == nil {
		return
	}
	return *o.Int1__
}

func (o Noozle) Int2() (res int) {
	if o.Version__ != 2 {
		panic("wrong case accessed")
	}
	if o.Int2__ == nil {
		return
	}
	return *o.Int2__
}

func NewNoozleWith1(v string) Noozle {
	return Noozle{
		Version__ : 1,
		Int1__ : &v,
	}
}

func NewNoozleWith2(v int) Noozle {
	return Noozle{
		Version__ : 2,
		Int2__ : &v,
	}
}

func NewNoozleDefault(version int) Noozle {
	return Noozle{
		Version__ : version,
	}
}

func (o Noozle) DeepCopy() Noozle {
	return Noozle {
		Version__: o.Version__,
		Int1__: (func (x *string) *string {
			if x == nil {
				return nil
			}
			tmp := (*x)
			return &tmp
		})(o.Int1__),
		Int2__: (func (x *int) *int {
			if x == nil {
				return nil
			}
			tmp := (*x)
			return &tmp
		})(o.Int2__),
	}
}

type Blurp struct {
	B__	bool	`codec:"b" json:"b"`
	True__	*string	`codec:"true,omitempty" json:"true,omitempty"`
	False__	*int	`codec:"false,omitempty" json:"false,omitempty"`
}

func (o *Blurp) B() (ret bool, err error) {
	switch (o.B__) {
		case true:
			if o.True__ == nil {
				err = errors.New("unexpected nil value for True__")
				return ret, err
			}
		case false:
			if o.False__ == nil {
				err = errors.New("unexpected nil value for False__")
				return ret, err
			}
	}
	return o.B__, nil
}

func (o Blurp) True() (res string) {
	if o.B__ != true {
		panic("wrong case accessed")
	}
	if o.True__ == nil {
		return
	}
	return *o.True__
}

func (o Blurp) False() (res int) {
	if o.B__ != false {
		panic("wrong case accessed")
	}
	if o.False__ == nil {
		return
	}
	return *o.False__
}

func NewBlurpWithTrue(v string) Blurp {
	return Blurp{
		B__ : true,
		True__ : &v,
	}
}

func NewBlurpWithFalse(v int) Blurp {
	return Blurp{
		B__ : false,
		False__ : &v,
	}
}

func (o Blurp) DeepCopy() Blurp {
	return Blurp {
		B__: o.B__,
		True__: (func (x *string) *string {
			if x == nil {
				return nil
			}
			tmp := (*x)
			return &tmp
		})(o.True__),
		False__: (func (x *int) *int {
			if x == nil {
				return nil
			}
			tmp := (*x)
			return &tmp
		})(o.False__),
	}
}

type Simple struct {
	S	*Blurp	`codec:"s,omitempty" json:"s,omitempty"`
}

func (o Simple) DeepCopy() Simple {
	return Simple{
		S: (func (x *Blurp) *Blurp {
			if x == nil {
				return nil
			}
			tmp := (*x).DeepCopy()
			return &tmp
		})(o.S),
	}
}

type Hash []byte
func (o Hash) DeepCopy() Hash {
	return (func (x []byte) []byte {
		if x == nil {
			return nil
		}
		return append([]byte{}, x...)
	})(o)
}

type Cat struct {
	_struct	bool	`codec:",toarray"`
	Bird	map[Blurp]Noozle	`codec:"bird" json:"bird"`
	Bee	map[string]Noozle	`codec:"bee" json:"bee"`
	Birds	map[Blurp][]Noozle	`codec:"birds" json:"birds"`
	Pickles	map[Blurp]int	`codec:"pickles" json:"pickles"`
	Penny	map[string]int	`codec:"penny" json:"penny"`
	Pa	map[int]string	`codec:"pa" json:"pa"`
	Wow	[]map[Blurp][]Noozle	`codec:"wow" json:"wow"`
	Boo	[]byte	`codec:"boo" json:"boo"`
	HooHah	Hash	`codec:"hooHah" json:"hooHah"`
	seqno	rpc.SeqNumber
}

func (o Cat) DeepCopy() Cat {
	return Cat{
		Bird: (func (x map[Blurp]Noozle) map[Blurp]Noozle {
			if x == nil {
				return nil
			}
			ret := make(map[Blurp]Noozle, len(x))
			for k, v := range x {
				kCopy := k.DeepCopy()
				vCopy := v.DeepCopy()
				ret[kCopy] = vCopy
			}
			return ret
		})(o.Bird),
		Bee: (func (x map[string]Noozle) map[string]Noozle {
			if x == nil {
				return nil
			}
			ret := make(map[string]Noozle, len(x))
			for k, v := range x {
				kCopy := k
				vCopy := v.DeepCopy()
				ret[kCopy] = vCopy
			}
			return ret
		})(o.Bee),
		Birds: (func (x map[Blurp][]Noozle) map[Blurp][]Noozle {
			if x == nil {
				return nil
			}
			ret := make(map[Blurp][]Noozle, len(x))
			for k, v := range x {
				kCopy := k.DeepCopy()
				vCopy := (func (x []Noozle) []Noozle {
					if x == nil {
						return nil
					}
					ret := make([]Noozle, len(x))
					for i, v := range x {
						vCopy := v.DeepCopy()
						ret[i] = vCopy
					}
					return ret
				})(v)
				ret[kCopy] = vCopy
			}
			return ret
		})(o.Birds),
		Pickles: (func (x map[Blurp]int) map[Blurp]int {
			if x == nil {
				return nil
			}
			ret := make(map[Blurp]int, len(x))
			for k, v := range x {
				kCopy := k.DeepCopy()
				vCopy := v
				ret[kCopy] = vCopy
			}
			return ret
		})(o.Pickles),
		Penny: (func (x map[string]int) map[string]int {
			if x == nil {
				return nil
			}
			ret := make(map[string]int, len(x))
			for k, v := range x {
				kCopy := k
				vCopy := v
				ret[kCopy] = vCopy
			}
			return ret
		})(o.Penny),
		Pa: (func (x map[int]string) map[int]string {
			if x == nil {
				return nil
			}
			ret := make(map[int]string, len(x))
			for k, v := range x {
				kCopy := k
				vCopy := v
				ret[kCopy] = vCopy
			}
			return ret
		})(o.Pa),
		Wow: (func (x []map[Blurp][]Noozle) []map[Blurp][]Noozle {
			if x == nil {
				return nil
			}
			ret := make([]map[Blurp][]Noozle, len(x))
			for i, v := range x {
				vCopy := (func (x map[Blurp][]Noozle) map[Blurp][]Noozle {
					if x == nil {
						return nil
					}
					ret := make(map[Blurp][]Noozle, len(x))
					for k, v := range x {
						kCopy := k.DeepCopy()
						vCopy := (func (x []Noozle) []Noozle {
							if x == nil {
								return nil
							}
							ret := make([]Noozle, len(x))
							for i, v := range x {
								vCopy := v.DeepCopy()
								ret[i] = vCopy
							}
							return ret
						})(v)
						ret[kCopy] = vCopy
					}
					return ret
				})(v)
				ret[i] = vCopy
			}
			return ret
		})(o.Wow),
		Boo: (func (x []byte) []byte {
			if x == nil {
				return nil
			}
			return append([]byte{}, x...)
		})(o.Boo),
		HooHah: o.HooHah.DeepCopy(),
		seqno: o.seqno,
	}
}

type messageID uint
func (o messageID) DeepCopy() messageID {
	return o
}

type BigBytes [10000]byte
func (o BigBytes) DeepCopy() BigBytes {
	var ret BigBytes
	copy(ret[:], o[:])
	return ret
}

type TeamInviteCategory int
const (
	TeamInviteCategory_NONE TeamInviteCategory = 0
	TeamInviteCategory_UNKNOWN TeamInviteCategory = 1
	TeamInviteCategory_KEYBASE TeamInviteCategory = 2
	TeamInviteCategory_EMAIL TeamInviteCategory = 3
	TeamInviteCategory_SBS TeamInviteCategory = 4
	TeamInviteCategory_SEITAN TeamInviteCategory = 5
	TeamInviteCategory_PHONE TeamInviteCategory = 6
)

func (o TeamInviteCategory) DeepCopy() TeamInviteCategory { return o }
var TeamInviteCategoryMap = map[string]TeamInviteCategory{
	"NONE": 0,
	"UNKNOWN": 1,
	"KEYBASE": 2,
	"EMAIL": 3,
	"SBS": 4,
	"SEITAN": 5,
	"PHONE": 6,
}

var TeamInviteCategoryRevMap = map[TeamInviteCategory]string{
	0: "NONE",
	1: "UNKNOWN",
	2: "KEYBASE",
	3: "EMAIL",
	4: "SBS",
	5: "SEITAN",
	6: "PHONE",
}

func (e TeamInviteCategory) String() string {
	if v, ok := TeamInviteCategoryRevMap[e]; ok {
		return v
	}
	return ""
}

type TeamInviteType struct {
	C__	TeamInviteCategory	`codec:"c" json:"c"`
	Unknown__	*string	`codec:"unknown,omitempty" json:"unknown,omitempty"`
	Sbs__	*int	`codec:"sbs,omitempty" json:"sbs,omitempty"`
}

func (o *TeamInviteType) C() (ret TeamInviteCategory, err error) {
	switch (o.C__) {
		case TeamInviteCategory_UNKNOWN:
			if o.Unknown__ == nil {
				err = errors.New("unexpected nil value for Unknown__")
				return ret, err
			}
		case TeamInviteCategory_SBS:
			if o.Sbs__ == nil {
				err = errors.New("unexpected nil value for Sbs__")
				return ret, err
			}
	}
	return o.C__, nil
}

func (o TeamInviteType) Unknown() (res string) {
	if o.C__ != TeamInviteCategory_UNKNOWN {
		panic("wrong case accessed")
	}
	if o.Unknown__ == nil {
		return
	}
	return *o.Unknown__
}

func (o TeamInviteType) Sbs() (res int) {
	if o.C__ != TeamInviteCategory_SBS {
		panic("wrong case accessed")
	}
	if o.Sbs__ == nil {
		return
	}
	return *o.Sbs__
}

func NewTeamInviteTypeWithUnknown(v string) TeamInviteType {
	return TeamInviteType{
		C__ : TeamInviteCategory_UNKNOWN,
		Unknown__ : &v,
	}
}

func NewTeamInviteTypeWithSbs(v int) TeamInviteType {
	return TeamInviteType{
		C__ : TeamInviteCategory_SBS,
		Sbs__ : &v,
	}
}

func NewTeamInviteTypeDefault(c TeamInviteCategory) TeamInviteType {
	return TeamInviteType{
		C__ : c,
	}
}

func (o TeamInviteType) DeepCopy() TeamInviteType {
	return TeamInviteType {
		C__: o.C__.DeepCopy(),
		Unknown__: (func (x *string) *string {
			if x == nil {
				return nil
			}
			tmp := (*x)
			return &tmp
		})(o.Unknown__),
		Sbs__: (func (x *int) *int {
			if x == nil {
				return nil
			}
			tmp := (*x)
			return &tmp
		})(o.Sbs__),
	}
}

type GetBazArg struct {
	R	R	`codec:"r" json:"r"`
	Beep	keybase1.DeviceID	`codec:"beep" json:"beep"`
}

type NotifierArg struct {
	I	int	`codec:"i" json:"i"`
}

type ProcessBigBytesArg struct {
	Bytes	BigBytes	`codec:"bytes" json:"bytes"`
}

// SampleInterface protocol is a sample among samples.
type SampleInterface interface {
	// GetBaz will get a baz like you wouldn't believe.
	// If this baz isn't gotten, then I'll eat my hat
	// 
	// And then.
	GetBaz(context.Context, GetBazArg) (keybase1.SigID,error)
	// Notifier notifies the notifiee.
	Notifier(context.Context, int) (error)
	// ProcessBigBytes will try to process a bunch of bytes.
	ProcessBigBytes(context.Context, BigBytes) (error)
}

func SampleProtocol(i SampleInterface) rpc.Protocol {
	return rpc.Protocol {
		Name: "sample.1.sample",
		Methods: map[string]rpc.ServeHandlerDescription{
			"getBaz": {
				MakeArg: func() interface{} {
					var ret [1]GetBazArg
					return &ret
				},
				Handler: func(ctx context.Context, args interface{}) (ret interface{}, err error) {
					typedArgs, ok := args.(*[1]GetBazArg)
					if !ok {
						err = rpc.NewTypeError((*[1]GetBazArg)(nil), args)
						return
					}
					ret, err = i.GetBaz(ctx, typedArgs[0])
					return
				},
			},
			"notifier": {
				MakeArg: func() interface{} {
					var ret [1]NotifierArg
					return &ret
				},
				Handler: func(ctx context.Context, args interface{}) (ret interface{}, err error) {
					typedArgs, ok := args.(*[1]NotifierArg)
					if !ok {
						err = rpc.NewTypeError((*[1]NotifierArg)(nil), args)
						return
					}
					err = i.Notifier(ctx, typedArgs[0].I)
					return
				},
			},
			"processBigBytes": {
				MakeArg: func() interface{} {
					var ret [1]ProcessBigBytesArg
					return &ret
				},
				Handler: func(ctx context.Context, args interface{}) (ret interface{}, err error) {
					typedArgs, ok := args.(*[1]ProcessBigBytesArg)
					if !ok {
						err = rpc.NewTypeError((*[1]ProcessBigBytesArg)(nil), args)
						return
					}
					err = i.ProcessBigBytes(ctx, typedArgs[0].Bytes)
					return
				},
			},
		},
	}
}

type SampleClient struct {
	Cli rpc.GenericClient
}

// GetBaz will get a baz like you wouldn't believe.
// If this baz isn't gotten, then I'll eat my hat
// 
// And then.
func (c SampleClient) GetBaz(ctx context.Context, __arg GetBazArg) (res keybase1.SigID,err error) {
	err = c.Cli.CallCompressed(ctx, "sample.1.sample.getBaz", []interface{}{__arg}, &res, rpc.CompressionGzip)
	return
}

// Notifier notifies the notifiee.
func (c SampleClient) Notifier(ctx context.Context, i int) (err error) {
	__arg := NotifierArg{ I : i }
	err = c.Cli.Notify(ctx, "sample.1.sample.notifier", []interface{}{__arg})
	return
}

// ProcessBigBytes will try to process a bunch of bytes.
func (c SampleClient) ProcessBigBytes(ctx context.Context, bytes BigBytes) (err error) {
	__arg := ProcessBigBytesArg{ Bytes : bytes }
	err = c.Cli.Call(ctx, "sample.1.sample.processBigBytes", []interface{}{__arg}, nil)
	return
}
