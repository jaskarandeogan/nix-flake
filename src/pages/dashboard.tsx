import './dashboard.css'
import { useAuth } from '@hooks'

export function Dashboard() {
  const { user, signOut } = useAuth()

  const meta = user?.user_metadata ?? {}
  const appMeta = user?.app_metadata ?? {}

  return (
    <div className="dashboard">
      <header className="dash-header">
        <div>
          <p className="eyebrow">Signed in</p>
          <h1 className="title">Welcome back{meta.full_name ? `, ${meta.full_name}` : ''}</h1>
          <p className="muted">{user?.email}</p>
        </div>
        <button onClick={signOut}>Sign out</button>
      </header>

      <div className="grid">
        <div className="panel">
          <div className="panel-header">
            <p className="eyebrow">Account</p>
            <span className="pill success">{user?.role ?? 'authenticated'}</span>
          </div>
          <dl className="meta">
            <div>
              <dt>Provider</dt>
              <dd>{meta.provider ?? appMeta.provider ?? '—'}</dd>
            </div>
            <div>
              <dt>Username</dt>
              <dd>{meta.username ?? '—'}</dd>
            </div>
            <div>
              <dt>Email verified</dt>
              <dd>{meta.email_verified ? 'Yes' : 'No'}</dd>
            </div>
            <div>
              <dt>Created</dt>
              <dd>{formatDate(user?.created_at)}</dd>
            </div>
            <div>
              <dt>Last sign-in</dt>
              <dd>{formatDate(user?.last_sign_in_at)}</dd>
            </div>
          </dl>
        </div>

        <div className="panel">
          <div className="panel-header">
            <p className="eyebrow">Metadata</p>
          </div>
          <dl className="meta two-col">
            <div>
              <dt>User ID</dt>
              <dd className="mono">{user?.id}</dd>
            </div>
            <div>
              <dt>Provider ID</dt>
              <dd className="mono">{meta.provider_id ?? '—'}</dd>
            </div>
            <div>
              <dt>Audience</dt>
              <dd>{user?.aud}</dd>
            </div>
            <div>
              <dt>Role</dt>
              <dd>{user?.role}</dd>
            </div>
            <div>
              <dt>Updated</dt>
              <dd>{formatDate(user?.updated_at)}</dd>
            </div>
          </dl>
        </div>

        <div className="panel">
          <div className="panel-header">
            <p className="eyebrow">Identities</p>
            <span className="pill neutral">{user?.identities?.length ?? 0}</span>
          </div>
          <div className="identity-list">
            {(user?.identities ?? []).map((identity) => (
              <div className="identity-card" key={identity.identity_id}>
                <div className="identity-main">
                  <div>
                    <p className="strong">{identity.provider}</p>
                    <p className="muted small">{identity.identity_data?.email ?? '—'}</p>
                  </div>
                  <span className="pill">{identity.last_sign_in_at ? 'Active' : 'Added'}</span>
                </div>
                <dl className="meta two-col">
                  <div>
                    <dt>Identity ID</dt>
                    <dd className="mono">{identity.identity_id}</dd>
                  </div>
                  <div>
                    <dt>Created</dt>
                    <dd>{formatDate(identity.created_at)}</dd>
                  </div>
                </dl>
              </div>
            ))}
            {(user?.identities ?? []).length === 0 && <p className="muted">No identities linked.</p>}
          </div>
        </div>
      </div>
    </div>
  )
}

function formatDate(value?: string | null) {
  if (!value) return '—'
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return value
  return date.toLocaleString()
}

