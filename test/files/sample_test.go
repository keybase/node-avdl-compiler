package sample1

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/keybase/client/go/protocol/keybase1"
	"github.com/keybase/go-codec/codec"
	"github.com/stretchr/testify/require"
)

type fakeSample struct{}

func (fakeSample) GetBaz(_ context.Context, _ GetBazArg) (keybase1.SigID, error) {
	return keybase1.SigID(""), nil
}

func (fakeSample) ProcessBigBytes(_ context.Context, _ BigBytes) error {
	return nil
}

func (fakeSample) Notifier(_ context.Context, _ int) error {
	return nil
}

func TestCall(t *testing.T) {
	protocol := SampleProtocol(fakeSample{})
	getBazDesc := protocol.Methods["getBaz"]
	args := getBazDesc.MakeArg()
	_, err := getBazDesc.Handler(context.Background(), args)
	require.NoError(t, err)
}

type fakeBytesArg struct {
	Bytes [1]byte `codec:"bytes" json:"bytes"`
}

func TestCallArgNoExpandOnDecode(t *testing.T) {
	var b []byte
	var h codec.MsgpackHandle
	encoder := codec.NewEncoderBytes(&b, &h)

	badArgs := make([]fakeBytesArg, 1000000)
	err := encoder.Encode(badArgs)
	require.NoError(t, err)

	protocol := SampleProtocol(nil)
	processBigBytesDesc := protocol.Methods["processBigBytes"]
	arg2 := processBigBytesDesc.MakeArg()

	decoder := codec.NewDecoderBytes(b, &h)

	// Test shouldn't hang here (i.e., it shouldn't try to decode
	// all but the first argument element of badArgs).
	err = decoder.Decode(arg2)
	require.NoError(t, err)
}

func TestOptionalKey(t *testing.T) {
	withWoop := R{
		Bar:  "blah blah",
		Baz:  "bluh bluh",
		Woop: "scoop woop",
	}
	output, err := json.Marshal(withWoop)
	require.NoError(t, err)
	require.Equal(t, string(output), `{"bar":"blah blah","baz_j_uid":"bluh bluh","woop":"scoop woop"}`)

	noWoop := R{
		Bar: "what's up",
		Baz: "hello",
	}
	output, err = json.Marshal(noWoop)
	require.NoError(t, err)
	require.Equal(t, string(output), `{"bar":"what's up","baz_j_uid":"hello"}`)
}
