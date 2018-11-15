package sample1

import (
	"testing"

	"github.com/keybase/client/go/protocol/keybase1"
	"github.com/keybase/go-codec/codec"
	"github.com/stretchr/testify/require"
	"golang.org/x/net/context"
)

type fakeSample struct{}

func (fakeSample) GetBaz(ctx context.Context, arg GetBazArg) (keybase1.SigID, error) {
	return keybase1.SigID(""), nil
}

func (fakeSample) ProcessBigBytes(ctx context.Context, arg BigBytes) error {
	return nil
}

func (fakeSample) Notifier(ctx context.Context, n int) error {
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
