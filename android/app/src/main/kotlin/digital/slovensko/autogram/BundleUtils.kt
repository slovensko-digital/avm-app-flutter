package digital.slovensko.autogram

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.core.os.BundleCompat.getParcelable

/** Gets the [Intent.EXTRA_STREAM] URI. */
internal val Bundle.stream: Uri?
    get() = getParcelable(this, Intent.EXTRA_STREAM, Uri::class.java)
